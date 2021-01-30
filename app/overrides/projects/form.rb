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

# Target is Redmines app/views/projects/_form.html.erb file
Deface::Override.new(
  virtual_path: 'projects/_form',
  name: 'disabled-module-names',
  replace: "erb[loud]:contains('check_box_tag')",
  text: "<%= check_box_tag 'enabled_module_names[]', m, @project.module_enabled?(m), :id => nil, :disabled => true %>",
  original: '5b2999dfbd5d56a30b26ab2f3a1944b89ae8798d',
  namespaced: true
)

Deface::Override.new(
  virtual_path: 'projects/_form',
  name: 'add-project-type',
  insert_top: 'div.box.tabular',
  text: "<%= call_hook(:view_projects_form_top, :project => @project, :f => f) %>",
  original: '5d0124c1829499ebafc294594acf1f585faf0938',
  namespaced: true
)

Deface::Override.new(
  virtual_path: 'projects/_form',
  name: 'remove-is-public-checkbox',
  remove: "erb[loud]:contains('f.check_box :is_public')",
  original: 'd1eb7f4396a41fc6033ffaf8c3c5626c9bb8d887',
  namespaced: true
)

Deface::Override.new(
  virtual_path: 'projects/_form',
  name: 'replace-note-on-project-visibility',
  replace: "erb[loud]:contains('Setting.login_required?')",
  text: "<% if @project.is_public? %><div class='warning'><%= Setting.login_required? ? l(:text_project_type_is_public_non_member) : l(:text_project_type_is_public_anonymous) %></div><% end %>",
  original: '5d02bcb05023a2d2af23178635bf027c36197068',
  namespaced: true
)