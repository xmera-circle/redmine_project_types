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

# Target is redmines app/views/custom_fields/_form.html.erb file
# Removes the list of projects from the custom_fields form since the the assignment
# to a specific project is already defined by the assingment to a tracker which is
# still possible.

Deface::Override.new(
  virtual_path: 'custom_fields/_index',
  name: 'disables-project-specific-table-columns',
  remove: "erb[silent]:contains('IssueCustomField')",
  closing_selector: "erb[silent]:contains('end')",
  original: 'f7d6b30d173528f6f51a99565b04b9560ab75706',
  namespaced: true
)
Deface::Override.new(
  virtual_path: 'custom_fields/_index',
  name: 'disables-project-specific-table-entries',
  remove: "erb[silent]:contains('if tab[:name]')",
  closing_selector: "erb[silent]:contains('end')",
  original: '3f3eee8b0b83eda2fade16a1a5a70027476470c7',
  namespaced: true
)
