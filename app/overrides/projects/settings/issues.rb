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

# Target is Redmines app/views/projects/settings/_issues.html.erb file
Deface::Override.new(
  virtual_path: 'projects/settings/_issues',
  name: 'disabled-trackers',
  replace: "erb[loud]:contains('tracker.id')",
  text: "<%= check_box_tag 'project[tracker_ids][]', tracker.id, @project.trackers.to_a.include?(tracker), :id => nil, :disabled => true %>",
  original: '2968122c1e535d6906a5e0fb82d30302b617e1bc',
  namespaced: true
)

Deface::Override.new(
  virtual_path: 'projects/settings/_issues',
  name: 'disabled-custom-fields',
  replace: "erb[loud]:contains('custom_field.id')",
  text: "<%= check_box_tag 'project[issue_custom_field_ids][]', custom_field.id, (@project.all_issue_custom_fields.include? custom_field),
        :id => nil, :disabled => true %>",
  original: '678ce8d0dbf350d65eca3d0b992daf7757d9df65',
  namespaced: true
)
