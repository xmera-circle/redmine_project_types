# Redmine plugin for xmera called Project Types Plugin.
#
# Copyright (C) 2017-19 Liane Hampe <liane.hampe@xmera.de>.
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

unless Rails.env == 'test'

Deface::Override.new(
  virtual_path: 'custom_fields/_form',
  name: 'disables-issue-related-lists',
  remove: "fieldset.box",
  namespaced: true,
  sequence: {before: "disables-project-list"}
)
Deface::Override.new(
  virtual_path: 'custom_fields/_form',
  name: 'disables-project-list',
  insert_after: "erb[silent]:contains('if @custom_field.is_a?(IssueCustomField)')",
  partial: "custom_fields/issue_related_fields",
  namespaced: true,
  sequence: {after: "disables-issue-related-lists"}
)

end