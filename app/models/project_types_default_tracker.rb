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

class ProjectTypesDefaultTracker < ActiveRecord::Base
  unloadable
  
  after_commit :sync_project_tracker
  
  belongs_to :project_type
  belongs_to :tracker

  validates_presence_of :tracker_id
  validates_uniqueness_of :tracker_id, :scope => :project_type_id
  attr_protected :id
  
  private
  
    def sync_project_tracker
      # The assignment of tracker to projects by the user within the project config 
      # is not enabled anymore. See app/overrides/projects/settings/form.
      # Instead the assignment is executed automatically in background based
      # on the project types which has the respective tracker defined.
      Project.all.each do |p|
        project_type_id = p.project_type_id if ProjectsProjectType.all.map(&:project_id).include?(p.id)
        return if project_type_id.nil?
        project_type = ProjectType.find(project_type_id)
        default_tracker_ids = project_type.project_types_default_trackers.collect{ |t| t.tracker_id }
        # Update of project trackers
        p.tracker_ids = default_tracker_ids
      end if (Project.any? && ProjectType.any?)
    end
  
end
