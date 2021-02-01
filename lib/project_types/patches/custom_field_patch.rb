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
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA

module ProjectTypes
  module Patches
    module CustomFieldPatch
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
        # The assignment of custom fields to projects by the user is not displayed
        # anymore. See app/overrides/custom_fields/form.
        # Instead the assignment is executed automatically in background based
        # on the tracker.
        # The relation is project -> project type -> tracker <-custom field.
        # That is, with every changing in the relation between custom fields and tracker
        # the relation between custom fields and projects needs to be synchronised.
        # The whole chain is: project -> project type -> tracker <-> custom field.
        # The following method defines: project -> project type -> tracker <- custom field.
        # 
        def sync_project_custom_fields
          # There are several types of custom fields. Relevant are only IssueCustomFields.
          # Each project has many trackers and many custom fields.
          # The relation project -> tracker (p.tracker_ids) is maintained by project_types_default_tracker.rb.
          # Therefore, p.tracker_ids is reliable.
          if ["IssueCustomField"].include?(self.class.to_s) && ProjectType.any?     
            Project.all.each do |p|
              intersection = p.tracker_ids & self.tracker_ids
              if intersection.empty?
                # Check whether to delete previously assigned custom fields of the project
                self.project_ids.delete(p.id)
              else
                # Update of projects custom fields
                self.project_ids += [p.id] unless self.project_ids.include?(p.id)
              end
            end if Project.any?
          end
        end
      end
    end
  end   
end

# Apply patch
Rails.configuration.to_prepare do
  unless CustomField.included_modules.include?(ProjectTypes::Patches::CustomFieldPatch)
    CustomField.prepend(ProjectTypes::Patches::CustomFieldPatch)
  end
end