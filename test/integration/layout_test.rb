# frozen_string_literal: true
#
# Redmine plugin for xmera called Project Types Plugin.
#
#  Copyright (C) 2017-18 Liane Hampe <liane.hampe@xmera.de>
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

require File.expand_path("#{File.dirname(__FILE__)}/../test_helper")
require File.expand_path("#{File.dirname(__FILE__)}/../load_fixtures")

class LayoutTest < Redmine::IntegrationTest
  include Redmine::I18n
  include RedmineProjectTypes::LoadFixtures

  fixtures :projects, :trackers, :issue_statuses, :issues,
           :enumerations, :users, :issue_categories,
           :projects_trackers,
           :roles,
           :member_roles,
           :members,
           :custom_fields, :custom_values,
           :custom_fields_projects, :custom_fields_trackers,
           :project_types,
           :enabled_project_type_modules

  def test_existence_of_project_type_field_in_any_project
    log_user('jsmith', 'jsmith')
    get settings_project_path(project(id: 2))
    assert_response :success
    assert_select '#project_project_type_id', 1
  end

  def test_existence_of_warning_for_public_projects
    log_user('admin', 'admin')
    get settings_project_path(project(id: 6, type: 2))
    assert_response :success
    assert_select '#project_project_type_id', 1
    assert_select '.warning', 1
  end

  def test_visibility_of_issues_when_module_enabled
    log_user('admin', 'admin')
    get project_issues_path(project(id: 1, type: 1))
    assert_response :success
    assert_select '#main-menu', 1
    assert_select '#main-menu a.issues', 1
    assert_select 'a[href="/issues/1"]', :text => /Cannot print recipes/
  end

  def test_non_existence_of_project_selection_for_custom_fields
    skip
    log_user('admin', 'admin')
    get edit_custom_field_path(id: 1)
    assert_response :success
    assert_select '#custom_field_project_ids', 0
  end

  def test_disabled_module_selection_in_project_settings
    skip
    log_user('jsmith', 'jsmith')
    project = Project.find(1)
    get settings_project_path(project)
    assert_response :success

    assert_select '#project_modules' do
      assert_select 'label.floating input[disabled=disabled]'
    end
  end

  def test_disabled_tracker_in_project_settings
    skip
    log_user('jsmith', 'jsmith')
    get settings_project_path(id: 1, tab: 'issues')
    assert_response :success
    assert_select '#project_trackers' do
      assert_select 'label.floating input[disabled=disabled]'
    end
  end

  def test_disabled_custom_fields_in_project_settings
    skip
    log_user('jsmith', 'jsmith')
      get settings_project_path(id: 1, tab: 'issues')
      assert_response :success
      assert_select '#project_issue_custom_fields' do
        assert_select 'label.floating input[disabled=disabled]'
      end
  end

  def project(id:, type: nil)
    project = Project.find(id.to_i)
    project.project_type_id = type
    project.save
    project
  end
end