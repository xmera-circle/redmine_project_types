# frozen_string_literal: true
#
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
          include ProjectTypes::EnabledModuleSwitch
          table_switch :enabled_modules, condition: :project_type_any?

          after_create :module_enabled
          after_update :module_enabled
          scope :has_module, lambda {|mod|
            where("#{Project.table_name}.id IN (SELECT em.project_id FROM #{EnabledProjectTypeModule.table_name} em WHERE em.name=?)", mod.to_s)
          }
        end
      end

      ##
      # Adds user as a project member with the default role of the project type.
      # Used when a non-admin user creates a project.
      #
      # @override This is overwritten from Project#add_default_member 
      #
      def add_default_member(user)
        return super(user) unless project_type_id.present?

        role = default_member_role
        member = Member.new(:project => self, :principal => user, :roles => [role])
        self.members << member
        member
      end

      private

      # after_create callback used to do things when a module is enabled
      def module_enabled
        if module_enabled?(:wiki) && wiki.nil?
          # Create a wiki with a default start page
          Wiki.create(:project => project, :start_page => 'Wiki')
        end
      end

      module ClassMethods
        def table_switch(table_name, condition: true)
          #after_initialize do |project|
          # before_save do |project|
            # self.class.enable_switch(table_name) if self.class.send condition
            self.enable_switch(table_name) unless core_test_run
          #end
        end

        def enable_switch(name)
          send name
        end

        def project_type_any?
          return false unless table_found? :project_types
        
          ProjectType.any?
        end

        def table_found?(table_name)
         connection.table_exists?(table_name)
        end

        def core_test_run
          !project_type_any? && Rails.env.test?
        end
      end

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