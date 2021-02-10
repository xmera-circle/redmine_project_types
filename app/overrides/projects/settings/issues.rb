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
  name: 'remove-trackers-from-project-settings',
  remove: '#project_trackers',
  original: 'a68a0c8d0bdb2791b8dfbaab3902352f28454484',
  disabled: ProjectTypes.missing?,
  namespaced: true
)

Deface::Override.new(
  virtual_path: 'projects/settings/_issues',
  name: 'remove-custom-fields-from-project-settings',
  remove: '#project_issue_custom_fields',
  original: '678ce8d0dbf350d65eca3d0b992daf7757d9df65',
  disabled: ProjectTypes.missing?,
  namespaced: true
)
