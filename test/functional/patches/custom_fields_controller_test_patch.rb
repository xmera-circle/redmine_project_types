# frozen_string_literal: true

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
class CustomFieldsControllerTest
  ##
  # See CustomFieldsControllerTest#should_create_new_issue_custom_fields
  # which is the substitute for this test.
  #
  define_method('test_new_issue_custom_field') do
    get :new, params: {
      type: 'IssueCustomField'
    }
    assert_response :success

    assert_select 'form#custom_field_form' do
      assert_select 'select#custom_field_field_format[name=?]', 'custom_field[field_format]' do
        assert_select 'option[value=user]', text: 'User'
        assert_select 'option[value=version]', text: 'Version'
      end

      # Visibility
      assert_select 'input[type=radio][name=?]', 'custom_field[visible]', 2
      assert_select 'input[type=checkbox][name=?]', 'custom_field[role_ids][]', 3
      # Projects
      assert_select 'input[type=checkbox][name=?]', 'custom_field[project_ids][]', 0
      assert_select 'input[type=hidden][name=?]', 'custom_field[project_ids][]', 1
      assert_select 'input[type=hidden][name=type][value=IssueCustomField]'
    end
  end
end
