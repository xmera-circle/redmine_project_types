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
  end
end
