# frozen_string_literal: true

#
# Redmine plugin for xmera called Project Types Plugin.
#
# Copyright (C) 2021 Liane Hampe <liaham@xmera.de>, xmera.
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
  module Switch
    module ProjectCustomFields
      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods
        def project_custom_fields
          unless included_modules.include?(ProjectTypes::Switch::ProjectCustomFields::InstanceMethods)
            send :include, ProjectTypes::Switch::ProjectCustomFields::InstanceMethods
          end
          unless reflect_on_association(:project_types)
            has_and_belongs_to_many :project_types,
                                    join_table: "#{table_name_prefix}custom_fields_project_types#{table_name_suffix}",
                                    foreign_key: 'custom_field_id',
                                    autosave: true,
                                    before_remove: :integrity_of_project_custom_fields

            safe_attributes 'project_type_ids'
          end
        end
      end

      module InstanceMethods
        def self.included(base)
          base.extend ClassMethods
        end

        def integrity_of_project_custom_fields(project_type)
          project_type.integrity_of_project_custom_fields(self, error_object: self)
        end

        module ClassMethods; end
      end
    end
  end
end
