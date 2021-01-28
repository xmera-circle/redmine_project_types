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
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA

module ProjectTypes
  module Patches
    module TrackerPatch
      # Calls the prepended modules on the class. Without this 
      # method the after_commit would be called on the module
      # what raises an error since the method is unknown for the
      # module IssueCloning::Patches::RolePatch.
      def self.prepended(mod)
         mod.singleton_class.prepend(ClassMethods)
         mod.prepend(InstanceMethods)
         mod.after_commit :sync_project_custom_fields
      end      
      
      module ClassMethods
        # empty
      end

      module InstanceMethods 
        private
        
        # The assignment of tracker to projects by the user is not displayed
        # anymore. See app/overrides/trackers/form.
        # Instead the assignment is executed automatically in background based
        # on the project types which has the respective tracker defined.
        # The relation is project -> project type -> tracker.
        # For custom fields there is the relation custom field <-> tracker. That is, 
        # with every changing in the relation between custom fields and tracker
        # the relation between custom fields and projects needs to be synchronised.
        # The whole chain is: project -> project type -> tracker <-> custom field.
        # The following method defines: project -> project type -> tracker -> custom field.
        #  
        def sync_project_custom_fields
          # Each project has many trackers and many custom fields.
          # The relation project -> tracker (self.projects, p.tracker_ids) is maintained by project_types_default_tracker.rb.
          # Therefore, p.tracker_ids is reliable.
          Project.all.each do |p|
            # Checks whether the project has the current tracker at all
            if p.tracker_ids.include?(self.id)
              # Distinction of cases
              a = p.issue_custom_field_ids
              b = self.custom_field_ids
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
                  # TODO: IS IT NECESSARY TO DELETE AT ALL? If there are always CF with trackers then not!
                  # p.issue_custom_field_ids = self.custom_field_ids unless (a-b).empty?
              end              
            end
          end if Project.any?
        end
      end
    end
  end   
end

# Apply patch
Rails.configuration.to_prepare do
  unless Tracker.included_modules.include?(ProjectTypes::Patches::TrackerPatch)
    Tracker.prepend(ProjectTypes::Patches::TrackerPatch)
  end
end