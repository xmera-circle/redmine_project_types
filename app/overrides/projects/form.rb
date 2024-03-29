# frozen_string_literal: true

#
# Redmine plugin for xmera called Project Types Plugin.
#
# Copyright (C) 2017-2023 Liane Hampe <liaham@xmera.de>, xmera Solutions GmbH.
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

# Target is Redmines app/views/projects/_form.html.erb file
Deface::Override.new(
  virtual_path: 'projects/_form',
  name: 'add-project-type-selection',
  insert_top: 'div.box.tabular',
  text: '<%= call_hook(:view_projects_form_top, :project => @project, :f => f) %>',
  original: '5d0124c1829499ebafc294594acf1f585faf0938',
  namespaced: true
)

Deface::Override.new(
  virtual_path: 'projects/_form',
  name: 'replace-project-custom-fields',
  replace: "erb[silent]:contains('@project.visible_custom_field_values.each do |value|')",
  closing_selector: "erb[silent]:contains('end')",
  partial: 'projects/project_custom_fields',
  original: '001961a490241e393156ca91d798b4c15dab1815',
  namespaced: true
)

Deface::Override.new(
  virtual_path: 'projects/_form',
  name: 'add-project-custom-field-settings',
  insert_before: "erb[silent]:contains('@project.safe_attribute?(')",
  partial: 'projects/project_custom_field_settings',
  original: '924f18a5fc0dce656322716232bab93bd5680fcc',
  namespaced: true
)
