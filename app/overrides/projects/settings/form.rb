# Redmine plugin for xmera called Project Types Plugin.
#
# Copyright (C) 2017-21 Liane Hampe <liaham@xmera.de>. xmera.
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

# Target is redmines app/views/projects/settings/_modules.html.erb file
Deface::Override.new(
  virtual_path: 'projects/settings/_modules',
  name: 'disabled-module-names',
  replace: "p label",
  text: "<p><label><%= check_box_tag 'enabled_module_names[]', m, @project.module_enabled?(m), :id => nil, :disabled => true -%>
 <%= l_or_humanize(m, :prefix => 'project_module_') %></label></p>",
  namespaced: true
)

# Target is redmines app/views/projects/_form.html.erb file
Deface::Override.new(
  virtual_path: 'projects/_form',
  name: 'add-project-type',
  insert_top: 'div.box.tabular',
  text: "<%= call_hook(:view_projects_form_top, :project => @project, :f => f) %>",
  namespaced: true
)
Deface::Override.new(
  virtual_path: 'projects/_form',
  name: 'disable-enabled-module-names',
  replace: "erb[silent]:contains('if @project.new_record? && @project.safe_attribute?')",
  text: "<% if @project.new_record? && @project.safe_attribute?('enabled_module_names') && Rails.env == 'test' %>",
  namespaced: true
)
Deface::Override.new(
  virtual_path: 'projects/_form',
  name: 'disabled-trackers',
  replace: "erb[loud]:contains('@project.trackers.to_a.include?(tracker)')",
  text: "<%= check_box_tag 'project[tracker_ids][]', tracker.id, @project.trackers.to_a.include?(tracker), :id => nil, :disabled => true %>",
  namespaced: true
)
Deface::Override.new(
  virtual_path: 'projects/_form',
  name: 'disabled-custom-fields',
  replace: "erb[loud]:contains('@project.all_issue_custom_fields.include?')",
  text: "<%= check_box_tag 'project[issue_custom_field_ids][]', custom_field.id, (@project.all_issue_custom_fields.include? custom_field),
        :disabled => (custom_field.is_for_all? ? 'disabled' : nil),
        :id => nil, :disabled => true %>",
  namespaced: true
)