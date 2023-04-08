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

# Target is Redmines app/views/projects/show.html.erb file
Deface::Override.new(
  virtual_path: 'projects/show',
  name: 'remove-custom-fields',
  remove: "erb[silent]:contains('render_custom_field_values(@project)')",
  closing_selector: "erb[silent]:contains('end')",
  original: 'dd9edde0aa32810f1effa2d612511ee12cfe5ee5',
  namespaced: true
)

Deface::Override.new(
  virtual_path: 'projects/show',
  name: 'add-custom-fields',
  insert_before: "erb[silent]:contains('if User.current.allowed_to?(:view_issues, @project)')",
  partial: 'projects/show_custom_fields',
  original: 'd736e71f5e5a2fd181033352638a9f58ad98d4c6',
  namespaced: true
)
