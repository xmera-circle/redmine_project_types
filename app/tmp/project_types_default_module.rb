# frozen_string_literal: true
#
# Redmine plugin for xmera called Project Types Plugin.
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

class ProjectTypesDefaultModule < ActiveRecord::Base
  after_commit :sync_project_module
  
  belongs_to :project_type
  
  validates_presence_of :name
  validates_uniqueness_of :name, :scope => :project_type_id
  
  private
  
    def sync_project_module
      # The assignment of modules to projects by the user within the project config 
      # is not enabled anymore. See app/overrides/projects/settings/form.
      # Instead the assignment is executed automatically in background based
      # on the project types which has the respective module defined.
      # @note self is the current default module to be saved.
      Project.all.each do |p|
        # Checks whether the project has a project type at all. If not, go to the next project.
        projects_project_type_id = p.project_type_id if ProjectsProjectType.all.map(&:project_id).include?(p.id)
        unless projects_project_type_id.nil?
          # Checks whether the project has the same project id as the current module to be saved.
          if self.project_type_id == projects_project_type_id
            project_type = ProjectType.find(project_type_id)
            # Includes the saved default modules which cumulate by every module to save
            default_module_names = project_type.project_types_default_modules.collect{ |t| t.name }
            # Update of project modules
            p.enabled_module_names = default_module_names
          end
        end
      end if (Project.any? && ProjectType.any?)
    end
end
