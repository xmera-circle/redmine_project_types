# frozen_string_literal: true

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

class ProjectTest
  define_method('test_safe_attributes_should_include_only_custom_fields_visible_to_user') do
    cf1 = ProjectCustomField.create!(name: 'Visible field',
                                     field_format: 'string',
                                     visible: false, role_ids: [1])
    cf2 = ProjectCustomField.create!(name: 'Non visible field',
                                     field_format: 'string',
                                     visible: false, role_ids: [3])
    user = User.find(2)
    project = Project.find(1)
    project.project_custom_field_ids = [cf1.id, cf2.id]
    project.save

    project.send :safe_attributes=, { 'custom_field_values' => {
      cf1.id.to_s => 'value1', cf2.id.to_s => 'value2'
    } }, user
    assert_equal 'value1', project.custom_field_value(cf1)
    assert_nil project.custom_field_value(cf2)

    project.send :safe_attributes=, { 'custom_fields' => [
      { 'id' => cf1.id.to_s, 'value' => 'valuea' },
      { 'id' => cf2.id.to_s, 'value' => 'valueb' }
    ] }, user
    assert_equal 'valuea', project.custom_field_value(cf1)
    assert_nil project.custom_field_value(cf2)
  end
end
