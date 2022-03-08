# frozen_string_literal: true

#
# Redmine plugin for xmera called Project Types Plugin.
#
# Copyright (C) 2017 - 2022 Liane Hampe <liaham@xmera.de>, xmera.
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

module Redmine
  module FieldFormat
    class ProjectTypeFormat < RecordList
      add 'project_type_master'
      self.form_partial = 'custom_fields/formats/project_type'
      self.customized_class_names = %w[Issue]
      field_attributes :additional_projects

      def possible_values_options(custom_field, _object = nil)
        all_options_for_select(custom_field)
      end

      def project_type_master_options
        ProjectType.masters_for_select.map { |option| [option.name, option.id.to_s] }
      end

      private

      def all_options_for_select(custom_field)
        blank_project_type_master_line | project_type_master_options | additional_projects_options(custom_field)
      end

      def blank_project_type_master_line
        ['', '']
      end

      def additional_projects_options(custom_field)
        projects_of_project_type(custom_field&.additional_projects).map { |option| [option.name, option.id.to_s] }
      end

      def projects_of_project_type(id)
        Project.projects.where(project_type_id: id)
      end
    end
  end
end
