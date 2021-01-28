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

class ProjectTypesDefaultTracker < ActiveRecord::Base
  # Callbacks
  after_commit :sync_project_tracker
  after_commit :sync_project_custom_fields
  
  belongs_to :project_type
  belongs_to :tracker

  validates_presence_of :tracker_id
  validates_uniqueness_of :tracker_id, :scope => :project_type_id
  
  private
  
    def sync_project_tracker
      # The assignment of tracker to projects by the user within the project config 
      # is not enabled anymore. See app/overrides/projects/settings/form.
      # Instead the assignment is executed automatically in background based
      # on the project types which has the respective tracker defined.
      # @note self is the current default tracker to be saved.
      #
      # Selects only such projects which have a project type at all 
      Project.select{ |p| ProjectsProjectType.all.map(&:project_id).include?(p.id) }.each do |p|
        projects_project_type_id = p.project_type_id 
        # Checks whether the project has the same project id as the current tracker to be saved.
        if self.project_type_id == projects_project_type_id
          project_type = ProjectType.find(project_type_id)
          # Includes the saved default modules which cumulate by every tracker to save
          default_tracker_ids = project_type.project_types_default_trackers.collect{ |t| t.tracker_id }
          # Update of project trackers
          p.tracker_ids = default_tracker_ids
        end
      end if Project.any?{ |p| ProjectsProjectType.all.map(&:project_id).include?(p.id) }
    end
    
    def sync_project_custom_fields
      # Each project has many trackers and many custom fields.
      # The relation project -> tracker (self.projects, p.tracker_ids) is maintained by project_types_default_tracker.rb.
      # Therefore, p.tracker_ids is reliable.
      #
      # Selects only such projects which have a project type at all 
      Project.select{ |p| ProjectsProjectType.all.map(&:project_id).include?(p.id) }.each do |p|
        # Checks whether the project has the current project type
        if p.project_type_id == self.project_type_id
          # Distinction of cases
          a = p.issue_custom_field_ids
          b = self.tracker.custom_field_ids
          # Case 1: a is real subset of b <=> b-a != {} <=> Add the custom fields of b-a.
          # Case 2: b is real subset of a <=> b-a  = {} <=> Delete the custom fields of a-b if a-b != {} AND a-b .
          diff = b-a
          case diff.empty?
            when false
              # Add the custom fields of diff to the current project
              p.issue_custom_field_ids += diff
              p.issue_custom_field_ids.flatten!
            when true
              # Delete the custom fields of a-b of the current project unless a-b is empty and a-b does not belong to other trackers
              # a = a - (a-b) = a - a + b = b
              #p.issue_custom_field_ids = self.tracker.custom_field_ids unless (a-b).empty?
          end              
        end
      end if Project.any?{ |p| ProjectsProjectType.all.map(&:project_id).include?(p.id) }
    end
  
  
end
