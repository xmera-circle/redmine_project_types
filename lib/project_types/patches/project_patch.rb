# Redmine plugin for xmera called Project Types Plugin..
#
# Copyright (C) 2017-19 Liane Hampe <liane.hampe@xmera.de>.
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

require_dependency 'project'

module ProjectTypes
  module Patches
    # Patches project.rb from Redmine Core
    module ProjectPatch
      def self.included(base)
        base.extend(ClassMethods) 
        base.send(:include, InstanceMethods)
        base.class_eval do
          unloadable # Send unloadable so it will not be unloaded in development
          # Associatons
          has_one :projects_project_type, dependent: :destroy
          accepts_nested_attributes_for :projects_project_type
          # Core Extensions (for class methods) --- no method defined yet
          # self.singleton_class.send(:alias_method, :project_types_next_identifier, :next_identifier)
          # Core Extensions (for instance methods)
          alias_method_chain :add_default_member, :project_type_default

        end
      end
      # Collects all class methods
      module ClassMethods

      end
      # Collects all instance methods
      module InstanceMethods
        # Sets all the attributes, e.g., projects default 
        # modules, and trackers, w.r.t. the underlying project type
        def project_types_default_values

          if self.projects_project_type.present? 
            if self.projects_project_type.project_type_id.present?
              # Delete all multi choice attributes first
              self.enabled_module_names = []
              self.trackers = []
              self.is_public = false
              self.save
                
              # Set all attributes according the underlying project type
              project_type_id = self.projects_project_type.project_type.id
              project_type = ProjectType.find(project_type_id)
              default = ProjectTypesDefaultTracker.where(project_type_id: project_type_id).pluck(:tracker_id).map(&:to_s)
    
              if project_type.is_public
                self.is_public = true
                self.save
              end
              
              self.enabled_module_names = ProjectTypesDefaultModule.where(project_type_id: project_type_id).pluck(:name)
              
              if default.is_a?(Array)
                self.trackers = Tracker.where(:id => default.map(&:to_i)).sorted.to_a
              else
                self.trackers = Tracker.sorted.to_a
              end
            end
          end
        end

        # Adds user as a project member with the default role of the project type
        # Used for when a non-admin user creates a project
        def add_default_member_with_project_type_default(user)
          if self.projects_project_type.present? 
            if self.projects_project_type.project_type_id.present?
              project_type_id = self.projects_project_type.project_type.id
              project_type = ProjectType.find(project_type_id)
              role_id = project_type.default_user_role_id
                  
              role = Role.givable.find_by_id(role_id) || Role.givable.first
              member = Member.new(:project => self, :principal => user, :roles => [role])
              self.members << member
              self.save
              member
            end
          else
            add_default_member_without_project_type_default(user)
          end
        end

        def type
          ProjectType.find(self.projects_project_type.project_type_id)
        end

        def relations
          ProjectsRelation.relations(self)
        end

        def relations?
          ProjectsRelation.relations?(self)
        end

        def relations_down
          ProjectsRelation.relations_down(self)
        end

        def relations_down?
          ProjectsRelation.relations_down?(self)
        end

        def relations_up
          ProjectsRelation.relations_up(self)
        end

        def relations_up?
          ProjectsRelation.relations_up?(self)
        end
        
        def project_type_id
          self.projects_project_type.project_type_id
        end
        
      end
    end
  end
end

# Apply patch
Rails.configuration.to_prepare do
  unless Project.included_modules.include?(ProjectTypes::Patches::ProjectPatch)
    Project.send(:include, ProjectTypes::Patches::ProjectPatch)
  end
end