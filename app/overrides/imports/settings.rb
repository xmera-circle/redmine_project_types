# frozen_string_literal: true

#
# Redmine plugin for xmera called Project Types Plugin.
#
# Copyright (C) 2022-2023 Liane Hampe <liaham@xmera.de>, xmera Solutions GmbH.
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

# Target is Redmines app/views/imports/settings.html.erb file
Deface::Override.new(
  virtual_path: 'imports/settings',
  name: 'remove-notification-label',
  remove: 'label[for=import_settings_notifications]',
  original: 'e6fc4f226646b6cef18b49f9d81aa3ae2c83abfc',
  namespaced: true
)

Deface::Override.new(
  virtual_path: 'imports/settings',
  name: 'remove-notification-fields',
  remove: "erb[loud]:contains('import_settings[notifications]')",
  original: '2394bc1800fbdf1da9bee5d0ba40fdb90c2ead8e',
  namespaced: true
)
