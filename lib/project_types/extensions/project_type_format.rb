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

module Redmine
  module FieldFormat
    class ProjectTypeFormat < RecordList
      add 'project_type_master'
      self.form_partial = 'custom_fields/formats/project_type'
      self.customized_class_names = %w[Issue]
      field_attributes :additional_projects

      def possible_values_options(_custom_field, _object = nil)
        project_type_master_options | additional_projects_options
      end

      def project_type_master_options
        ProjectType.masters_for_select.map { |option| [option.name, option.id.to_s] }
      end

      def additonal_projects_options
        ProjectType.projects.where(project_type: additonal_projects)
      end
    end
  end
end
