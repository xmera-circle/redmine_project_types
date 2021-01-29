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
          delegate :is_public, :is_public?, :default_member_role, to: :project_type, allow_nil: true

          safe_attributes(redefine_attribute_names)
        end
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
        # Marking projects as public should only be possible at the project
        # type level.
        #
        # @note: @safe_attributes is a nested array of size 3
        #
        def redefine_attribute_names
          @safe_attributes.first.first.replace(redefined)
        end

        def redefined
          given - ['is_public'] + ['project_type_id']
        end

        def given
          @safe_attributes.first.first
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