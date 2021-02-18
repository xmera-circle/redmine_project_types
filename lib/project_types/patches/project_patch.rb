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
    # Patches project.rb from Redmine Core
    module ProjectPatch
      def self.prepended(base)
        base.extend(ClassMethods)
        base.prepend(InstanceMethods)
        base.class_eval do
          include Redmine::I18n
          include ProjectTypes::Switch::Modules
          after_initialize do
            enable_switch(:enabled_modules) if ProjectTypes.any?
          end

          after_commit do |project|
            if ProjectTypes.any?
              project.synchronise_modules
              project.synchronise_projects_trackers
            end
          end

          before_validation :revise_project_type_dependencies
          validate :presence_of_project_type_id
        end
      end

      module ClassMethods
        ##
        # This switch will be checked only once. That is, the condition needs
        # to hold during the whole runtime. A change would not be considered.
        #
        # @note: Use this method interchangeable with the callback above!
        #
        def enable_switch(name)
          send name
        end
      end

      module InstanceMethods
        def enable_switch(name)
          self.class.enable_switch(name)
        end

        ##
        # Adds user as a project member with the default role of the project type.
        # Used when a non-admin user creates a project.
        #
        # @override This is overwritten from Project#add_default_member
        #
        def add_default_member(user)
          return super(user) unless project_type_id.present?

          role = default_member_role
          member = Member.new(project: self, principal: user, roles: [role])
          members << member
          member
        end

        ##
        # Defines the available_custom_fields in dependence of the underlying
        # project type.
        #
        # @override Overwrites Project#available_custom_fields defined
        #   by acts_as_customizable plugin.
        #
        def available_custom_fields
          new_record? || project_type_id.nil? ? [] : project_type.project_custom_fields.sorted.to_a
        end

        ##
        # Selects only those custom_fields and its values when they are
        # assigned to the projects project_type.
        #
        # @override This is overwritten from Project#visible_custom_field_values
        #
        def visible_custom_field_values(user = nil)
          return super(user) unless project_type_id.present? || ProjectTypes.any?

          user ||= User.current
          custom_field_values.select do |value|
            value.custom_field.project_type_ids.include?(project_type_id) &&
              value.custom_field.visible_by?(project, user)
          end
        end

        ##
        # A change in the project type will delete custom field values of the
        # project type which was set before the change!
        #
        def revise_project_type_dependencies
          return unless ProjectTypes.any?

          # prevent_custom_fields_from_deletion
          delete_custom_fields_after_project_type_reassignment
        end

        private

        ##
        # When a project type of the underlying project changes the assigned
        # project custom fields will be checked. If they store values a validation
        # error is raised. Otherwise, the project custom values are reset to nil
        # in order to avoid collision between the fields of the changing
        # project types. This matters especially when the previous project type
        # has required fields since the display of the fields does not change
        # when selecting another type. Hence. the old data of the project
        # custom field will be send to the controller and may cause conflicts.
        #
        def prevent_custom_fields_from_deletion
          if custom_field_values_changed? && project_type_id_changed? && values_present?
            errors.add :base, l(:error_can_not_change_project_type)
          elsif project_type_id_changed?
            reset_project_custom_values!
          end
        end

        ##
        # This method will delete the custom field values even if they have
        # are not empty.
        #
        def delete_custom_fields_after_project_type_reassignment
          reset_project_custom_values! if project_type_id_changed? && custom_field_values_changed?
        end

        def values_present?
          custom_field_values.any?(&:value_present?)
        end

        def presence_of_project_type_id
          return unless ProjectTypes.any?

          errors.add :project_type, :error_project_type_missing unless project_type_id.present?
        end

        ##
        # This method is analogous to
        # Redmine::Acts::Customizable::InstanceMethods#reset_custom_values! but
        # it does not mark the values as changed in order to avoid the
        # validation in
        # Redmine::Acts::Customizable::InstanceMethods#validate_custom_field_values.
        #
        # This is necessary since changes in the project_type come along with
        # another set of project custom_fields. However, the custom field
        # validation refers always to the values of the previous project_type's
        # project custom fields.
        #
        # @note: Existing custom field values will be deleted!
        #
        def reset_project_custom_values!
          @custom_field_values = nil
          @custom_field_values_changed = false
        end
      end
    end
  end
end

# Apply patch
Rails.configuration.to_prepare do
  unless Project.included_modules.include?(ProjectTypes::Patches::ProjectPatch)
    Project.prepend ProjectTypes::Patches::ProjectPatch
  end
end
