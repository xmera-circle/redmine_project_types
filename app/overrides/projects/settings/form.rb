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

# Target is redmines app/views/projects/settings/_modules.html.erb file
Deface::Override.new(
  virtual_path: 'projects/settings/_modules',
  name: 'disabled-module-names',
  replace: "p label",
  text: "<p><label><%= check_box_tag 'enabled_module_names[]', m, @project.module_enabled?(m), :id => nil, :disabled => true -%>
 <%= l_or_humanize(m, :prefix => 'project_module_') %></label></p>",
  namespaced: true
)

