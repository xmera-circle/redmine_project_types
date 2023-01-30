# frozen_string_literal: true

#
# Redmine plugin for xmera called Project Types Plugin.
#
# Copyright (C) 2017-2023 Liane Hampe <liaham@xmera.de>, xmera Solutions GmbH.
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
  virtual_path: 'custom_fields/_form',
  name: 'disables-project-list',
  replace: "erb[silent]:contains('if @custom_field.is_a?(IssueCustomField)')",
  closing_selector: "erb[silent]:contains('end')",
  partial: 'custom_fields/issue_related_fields',
  original: 'f53df0d8c1849ed72ee3f418def77fe73cd43c5b',
  namespaced: true
)
