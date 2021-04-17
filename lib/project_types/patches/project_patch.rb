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
        base.singleton_class.prepend(ClassMethods)
        base.prepend(InstanceMethods)
        base.class_eval do
          before_validation :add_prefix_to_project_type_master_identifier, on: :create

          belongs_to :project_type, -> { where(is_project_type: true) },
                     foreign_key: :project_type_id,
                     inverse_of: :relatives

          has_and_belongs_to_many :project_custom_fields,
                                  -> { order(:position) },
                                  class_name: 'ProjectCustomField',
                                  join_table: "#{table_name_prefix}custom_fields_projects#{table_name_suffix}",
                                  association_foreign_key: 'custom_field_id'

          scope :projects, -> { where(is_project_type: false).sorted }

          safe_attributes :project_type_id, :is_project_type, :project_custom_field_ids

          validate :validate_project_type_master_role
        end
      end

      module ClassMethods
        ##
        # Extends with project custom fields.
        #
        # @override Project#copy_from
        #
        def copy_from(project)
          copy = super(project)
          project = project.is_a?(Project) ? project : Project.find(project)
          copy.project_custom_fields = project.project_custom_fields
          copy
        end
      end

      module InstanceMethods
        ##
        # Replace missing project types with its null object.
        #
        def project_type
          super || NullProjectType.new
        end

        ##
        # Sorts out fields not belonging to a project or project type.
        #
        # @override Project#visible_custom_field_values
        #
        def visible_custom_field_values(user = nil)
          ids = project_custom_field_ids
          return super if new_record? && ids.empty?

          user ||= User.current
          custom_field_values.select do |value|
            next unless ids.include? value.custom_field.id

            value.custom_field.visible_by?(project, user)
          end
        end

        def project_type_master?
          is_project_type
        end

        def not_project_type_master?
          !project_type_master?
        end

        def no_project_type_id?
          !project_type_id
        end

        ##
        # A default project has no project type and is not a project type master.
        # It is just a project as it is in pure Redmine.
        #
        def default_project?
          no_project_type_id? && not_project_type_master?
        end

        private

        def validate_project_type_master_role
          return unless project_type_id && is_project_type

          errors.add :project, l(:error_project_type_master_can_not_have_project_type)
        end

        def add_prefix_to_project_type_master_identifier
          return unless project_type_master?

          identifier.prepend(l(:label_prefix_project_type_master_identifier))
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
