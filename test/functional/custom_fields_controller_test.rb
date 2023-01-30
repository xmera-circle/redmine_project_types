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

require File.expand_path("#{File.dirname(__FILE__)}/../test_helper")

module ProjectTypes
  class CustomFieldsControllerTest < ActionDispatch::IntegrationTest
    extend ProjectTypes::LoadFixtures
    include ProjectTypes::AuthenticateUser
    include ProjectTypes::ProjectTypeCreator

    fixtures :projects, :versions, :users, :email_addresses, :roles, :members,
             :member_roles, :issues, :journals, :journal_details,
             :trackers, :projects_trackers, :issue_statuses,
             :enabled_modules, :enumerations, :boards, :messages,
             :attachments, :custom_fields, :custom_values, :time_entries,
             :wikis, :wiki_pages, :wiki_contents, :wiki_content_versions,
             :custom_fields_trackers, :custom_fields_projects

    def setup
      log_user('admin', 'admin')
    end

    test 'should create new issue custom field' do
      create_project_type(name: 'ProjectType2').relative_ids = [1]
      create_project_type(name: 'ProjectType3').relative_ids = [2]
      create_project_type(name: 'ProjectType4').relative_ids = [3]

      get new_custom_field_path, params: { type: 'IssueCustomField' }
      assert_response :success

      assert_select 'input[type=checkbox][name=?]', 'custom_field[project_ids][]', 6
      assert_select 'input[type=hidden][name=?]', 'custom_field[project_ids][]'
      assert_select 'input[type=hidden][name=type][value=IssueCustomField]'
    end

    test 'should create project custom field with default value' do
      create_project_type(name: 'ProjectType2').relative_ids = [1]
      create_project_type(name: 'ProjectType3').relative_ids = [2]
      create_project_type(name: 'ProjectType4').relative_ids = [3]

      post custom_fields_path, params: { type: 'ProjectCustomField',
                                         custom_field: {
                                           name: 'test_post_new_list',
                                           default_value: '--Please select--',
                                           min_length: '0',
                                           searchable: '0',
                                           regexp: '',
                                           is_for_all: '1',
                                           possible_values: "0.1\n0.2\n",
                                           max_length: '0',
                                           is_filter: '0',
                                           is_required: '0',
                                           field_format: 'list',
                                           tracker_ids: ['1', '']
                                         } }
      assert_redirected_to custom_fields_path({ tab: 'ProjectCustomField' })
      assert_equal 'test_post_new_list', ProjectCustomField.last.name
    end

    test 'should render hidden issue custom field project ids for plain project' do
      project = Project.find(1)
      assert project.project_type_id.nil?
      CustomField.find(1).projects << project
      assert project.issue_custom_fields.pluck(:id).include? 1

      get edit_custom_field_path(id: 1), params: { type: 'IssueCustomField' }
      assert_response :success
      assert_select 'input[type=hidden][name=?][value=?]', 'custom_field[project_ids][]', '1'
    end

    test 'should render hidden project custom field project ids for plain project' do
      project = Project.find(1)
      assert project.project_type_id.nil?
      CustomField.find(3).projects << project
      assert project.project_custom_fields.pluck(:id).include? 3

      get edit_custom_field_path(id: 3), params: { type: 'IssueCustomField' }
      assert_response :success
      assert_select 'input[type=hidden][name=?][value=?]', 'custom_field[project_ids][]', '1'
    end
  end
end
