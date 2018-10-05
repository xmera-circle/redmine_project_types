# Redmine plugin for xmera:isms called Project Types Plugin
#
# Copyright (C) 2017-18 Liane Hampe <liane.hampe@xmera.de>
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
  text: "<% if @project.new_record? && @project.safe_attribute?('enabled_module_names') && !Redmine::Plugin.installed?('project_types') %>",
  namespaced: true
)
Deface::Override.new(
  virtual_path: 'projects/_form',
  name: 'disable-trackers',
  replace: "erb[silent]:contains('if @project.new_record? || @project.module_enabled?')",
  text: "<% if !Redmine::Plugin.installed?('project_types') && (@project.new_record? || @project.module_enabled?('issue_tracking')) ||  (!@project.new_record? && @project.module_enabled?('issue_tracking'))%>",
  namespaced: true
)
