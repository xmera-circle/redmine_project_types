# Redmine plugin for xmera called Project Types Plugin.
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

class ProjectTypesDefaultModule < ActiveRecord::Base
  unloadable
  
  after_commit :sync_project_module
  
  belongs_to :project_type
  
  validates_presence_of :name
  validates_uniqueness_of :name, :scope => :project_type_id
  attr_protected :id
  
  private
  
    def sync_project_module
      # Updates the projects module defined by the associated project type
      Project.all.each do |p|
        project_type_id = p.project_type_id if ProjectsProjectType.all.map(&:project_id).include?(p.id)
        return if project_type_id.nil?
        project_type = ProjectType.find(project_type_id)
        default_module_names = project_type.project_types_default_modules.collect{ |t| t.name }
        # Update of project modules
        p.enabled_module_names = default_module_names
      end if (Project.any? && ProjectType.any?)
    end
end
