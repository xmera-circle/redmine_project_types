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

module ProjectTypes
  module Extensions
    module ProjectCustomFieldPatch
      def self.included(base)
        base.extend(ClassMethods)
        base.include(InstanceMethods)
        base.class_eval do
          has_and_belongs_to_many :projects,
                                  join_table: "#{table_name_prefix}custom_fields_projects#{table_name_suffix}",
                                  foreign_key: 'custom_field_id',
                                  autosave: true

          safe_attributes 'project_ids'
        end
      end

      module ClassMethods
        def fields_for_select
          ProjectCustomField.sorted.select(:id, :name, :description)
        end
      end

      module InstanceMethods
        private

        def not_project_custom_field?(custom_value)
          !custom_value.customized.project_custom_field_ids.include?(custom_value.custom_field.id)
        end

        def nothing_to_validate?(custom_value)
          return true unless custom_value.customized

          new_project?(custom_value)
        end

        def new_project?(custom_value)
          custom_value.customized.id.nil?
        end
      end
    end
  end
end

# Apply patch
Rails.configuration.to_prepare do
  unless ProjectCustomField.included_modules.include?(ProjectTypes::Extensions::ProjectCustomFieldPatch)
    ProjectCustomField.include ProjectTypes::Extensions::ProjectCustomFieldPatch
  end
end
