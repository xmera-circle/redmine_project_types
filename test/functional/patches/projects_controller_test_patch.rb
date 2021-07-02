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
class ProjectsControllerTest
  define_method('test_show_should_not_display_blank_custom_fields_with_multiple_values') do
    f1 = ProjectCustomField.generate! field_format: 'list', possible_values: %w[Foo Bar], multiple: true
    f2 = ProjectCustomField.generate! field_format: 'list', possible_values: %w[Baz Qux], multiple: true
    project = Project.generate!(custom_field_values: { f2.id.to_s => %w[Qux] })

    get :show, params: {
      id: project.id
    }
    assert_response :success

    assert_select 'li', text: /#{f1.name}/, count: 0
    assert_select 'li', text: /#{f2.name}/, count: 0
  end

  define_method('test_show_should_display_visible_custom_fields') do
    ProjectCustomField.find_by_name('Development status').update_attribute :visible, true
    get :show, params: {
      id: 'ecookbook'
    }
    assert_response :success

    assert_select 'li[class=?]', 'cf_3', text: /Development status/, count: 0
  end

  define_method('test_update_custom_field_should_update_updated_on') do
    @request.session[:user_id] = 2
    project = Project.find(1)
    project.update_attribute :updated_on, nil
    project.project_custom_fields << ProjectCustomField.find(3)
    assert_equal 'Stable', project.custom_value_for(3).value

    travel_to Time.current do
      post(
        :update,
        :params => {
          :id => 1,
          :project => {
            :custom_field_values => {'3' => 'Alpha'}
          }
        }
      )
      assert_redirected_to '/projects/ecookbook/settings'
      assert_equal 'Successful update.', flash[:notice]
      project.reload
      assert_equal 'Alpha', project.custom_value_for(3).value
      assert_equal Time.current, project.updated_on
    end
  end
end
