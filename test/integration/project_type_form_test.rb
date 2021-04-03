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

module ProjectTypes
  class ProjectTypeFormTest < Redmine::IntegrationTest
    extend ProjectTypes::LoadFixtures
    include ProjectTypes::AuthenticateUser
    include ProjectTypes::ProjectTypeCreator
    include Redmine::I18n

    fixtures :projects, :issue_statuses, :issues,
             :enumerations, :issue_categories,
             :projects_trackers, :trackers,
             :roles, :member_roles, :members, :users,
             :custom_fields, :custom_values,
             :custom_fields_projects, :custom_fields_trackers

    test 'should identify project type index page' do
      log_user('admin', 'admin')
      get project_types_path
      assert_response :success
      assert_match l(:label_project_type_plural), response.body
    end

    test 'should display project type box in trackers' do
      log_user('admin', 'admin')
      get edit_tracker_path(id: 1)
      assert_response :success
      assert_select '#tracker_project_ids'
      assert_match l(:label_project_type_plural), response.body
    end

    test 'should display project type box in custom fields' do
      log_user('admin', 'admin')
      get edit_custom_field_path(id: 1)
      assert_response :success
      assert_select '#custom_field_project_ids'
      assert_match l(:label_project_type_plural), response.body
    end
  end
end
