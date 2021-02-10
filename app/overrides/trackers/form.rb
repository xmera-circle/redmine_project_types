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

# Target is redmines app/views/trackers/_form.html.erb file
Deface::Override.new(
  virtual_path: 'trackers/_form',
  name: 'remove-project-list',
  replace: 'div.splitcontentright',
  partial: 'trackers/project_types',
  disabled: ProjectTypes.missing?,
  original: '570b247e7ac59c8c751282f89dd9011b7fe6f945',
  namespaced: true
)
Deface::Override.new(
  virtual_path: 'trackers/_form',
  name: 'remove-custom-field-list',
  remove: "erb[silent]:contains('if @issue_custom_fields.present?')",
  closing_selector: "erb[silent]:contains('end')",
  disabled: ProjectTypes.missing?,
  original: 'f78ee40e91e9a5c255510544e02182d9c3da046d',
  namespaced: true
)
