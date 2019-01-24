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
  
        def sync_project_custom_fields
          # Updates the projects custom fields defined by the associated
          # project type.
          if ["IssueCustomField"].include?(self.class.to_s) && ProjectType.any?
            Project.all.each do |p|
              intersection = p.tracker_ids & self.tracker_ids  
              unless intersection.empty?
                # Update of project custom fields
                union = p.issue_custom_field_ids << self.id
                p.issue_custom_field_ids = union.uniq
              end
            end if Project.all
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