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
  module Patches
    module ProjectCustomFieldPatch
      def self.prepended(base)
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

      module ClassMethods; end

      module InstanceMethods

        ##
        # Validate only those project custom fields which belong to the 
        # project. Values of fields don't belonging to the underlying project (type)
        # are ignored. Values of projects having no project type are validated
        # as in a default Redmine instance.
        #
        # @override CustomField#validate_custom_value
        #
        # Returns the error messages for the given value
        # or an empty array if value is a valid value for the custom field
        def validate_custom_value(custom_value)
          return [] if new_project?(custom_value) || not_project_custom_field?(custom_value)

          super
        end

        private

        def not_project_custom_field?(custom_value)
          !custom_value.customized.project_custom_field_ids.include?(custom_value.custom_field.id)
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
  unless ProjectCustomField.included_modules.include?(ProjectTypes::Patches::ProjectCustomFieldPatch)
    ProjectCustomField.prepend ProjectTypes::Patches::ProjectCustomFieldPatch
  end
end
