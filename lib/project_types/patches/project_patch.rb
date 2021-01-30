# Redmine plugin for xmera called Project Types Plugin..
#
# Copyright (C) 2017-21 Liane Hampe <liaham@xmera.de>, xmera.
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.

# require_dependency 'project'

module ProjectTypes
  module Patches
    # Patches project.rb from Redmine Core
    module ProjectPatch
      def self.prepended(base)
        base.extend(ClassMethods) 
        base.class_eval do
          belongs_to :project_type
          has_many :project_type_modules, class_name: 'EnabledModule', foreign_key: :project_type_id, dependent: :delete_all
          
          delegate :is_public, :is_public?, :default_member_role, to: :project_type, allow_nil: true

          safe_attributes :project_type_id
          delete_safe_attribute_names :is_public, :enabled_module_names
        end
      end


      ##
      # Reassigns all calls of enabled_modules to the association as defined in 
      # project_type_modules
      # 
      def enabled_modules
        if self.project_type_id.present?
          self.class.delete_safe_attribute_names :enabled_module_names
          self.enabled_modules = self.project_type_modules
        else
          self.class.safe_attributes(
            'enabled_module_names',
            :if =>
              lambda {|project, user|
                if project.new_record?
                  if user.admin?
                    true
                  else
                    default_member_role.has_permission?(:select_project_modules)
                  end
                else
                  user.allowed_to?(:select_project_modules, project)
                end
              })
        end
        super
      end

      ##
      # Adds user as a project member with the default role of the project type.
      # Used when a non-admin user creates a project.
      #
      # @override This is overwritten from Project#add_default_member 
      #
      def add_default_member(user)
        return super(user) unless project_type.present?

        role = default_member_role
        member = Member.new(:project => self, :principal => user, :roles => [role])
        self.members << member
        member
      end

      module ClassMethods
        ##
        # Attributes handled by the projects project_type are not allowed
        # to manipulate in the project directly.
        #
        # @note: @safe_attributes is a nested array with 3 levels:
        #   [[[list], {option}], [[list], {option}], ...] where list contains
        #   the names of the safe attributes.
        #
        def delete_safe_attribute_names(*args)
          return if args.empty?
          attributes = []
          @safe_attributes.collect do |elements, options|
            args.each do |name|
              elements.delete(name.to_s)
            end
            attributes << [elements, options] unless elements.empty?
          end
          @safe_attributes = attributes
        end
      end

      # Collects all instance methods
      module InstanceMethods
        # Sets all the attributes, e.g., projects default modules,
        # and trackers, w.r.t. the underlying project type
        # def project_types_default_values
        #   if self.project_type.present? 
        #     # Delete all multi choice attributes first
        #     #self.enabled_module_names = []
        #     #self.trackers = []
        #     self.is_public = self.project_type.is_public
        #     self.save
                
        #       # Set all attributes according the underlying project type
        #       project_type_id = self.projects_project_type.project_type.id
        #       project_type = ProjectType.find(project_type_id)
        #       default = ProjectTypesDefaultTracker.where(project_type_id: project_type_id).pluck(:tracker_id).map(&:to_s)
    
        #       if project_type.is_public
        #         self.is_public = true
        #         self.save
        #       end

        #       self.enabled_module_names = ProjectTypesDefaultModule.where(project_type_id: project_type_id).pluck(:name)
              
        #       if default.is_a?(Array)
        #         self.trackers = Tracker.where(:id => default.map(&:to_i)).sorted.to_a
        #       else
        #         self.trackers = Tracker.sorted.to_a
        #       end

        #   end
        # end   
      end
    end
  end
end

# Apply patch
Rails.configuration.to_prepare do
  unless Project.included_modules.include?(ProjectTypes::Patches::ProjectPatch)
    Project.send(:prepend, ProjectTypes::Patches::ProjectPatch)
  end
end