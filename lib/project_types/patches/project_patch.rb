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
                
          after_initialize do |project|
            enable_switch(:enabled_modules) if project_type_any?
          end

          after_commit do |project|
            project.synchronize_modules if project_type_any?
          end 
        end
      end

      def project_type_any?
        self.class.project_type_any?
      end

      def enable_switch(name)
        self.class.enable_switch(name)
      end

      def synchronize_modules
        project_type&.synchronize_modules
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

      module ClassMethods
        ##
        # This switch will be checked only once. That is, the condition needs
        # to hold during the whole runtime. A change would not be considered.
        #
        # @note: Use this method interchangeable with the callback above!
        #
        def table_switch(table_name, callback: nil, condition: true)
          self.enable_switch(table_name) if send condition
        end

        def enable_switch(name)
          send name
        end

        #### CONDITIONS ####

        ##
        # Preferred condition which works in all environments
        #
        def project_type_any?
          return false unless table_found?
        
          ProjectType.any?
        end

        def table_found?(table_name = :project_types)
         connection.table_exists?(table_name)
        end

        ##
        # The table will be found even when running core tests.
        #
        def plugin_test_run
          table_found? && Rails.env.test?
        end

        ##
        # When this condition will be checked before any test (core, plugin)
        # there is never a project type since it will be loaded later.
        #
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