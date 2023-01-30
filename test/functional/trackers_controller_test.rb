# frozen_string_literal: true

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

require File.expand_path("#{File.dirname(__FILE__)}/../test_helper")

module ProjectTypes
  class TrackersControllerTest < ActionDispatch::IntegrationTest
    extend ProjectTypes::LoadFixtures
    include ProjectTypes::AuthenticateUser
    include ProjectTypes::ProjectTypeCreator

    fixtures :projects, :versions, :users, :email_addresses, :roles, :members,
             :member_roles, :issues, :journals, :journal_details,
             :trackers, :projects_trackers, :issue_statuses,
             :enabled_modules, :enumerations, :boards, :messages,
             :attachments, :custom_fields, :custom_values, :time_entries,
             :wikis, :wiki_pages, :wiki_contents, :wiki_content_versions

    def setup
      log_user('admin', 'admin')
    end

    test 'should find editable trackers' do
      create_project_type(name: 'ProjectType2').relative_ids = [1]
      create_project_type(name: 'ProjectType3').relative_ids = [2]
      create_project_type(name: 'ProjectType4').relative_ids = [3]

      tracker = Tracker.find(1)
      tracker.project_ids = [1, 3]

      get edit_tracker_path(id: 1)
      assert_response :success

      assert_select 'input[name=?][value="1"][checked=checked]', 'tracker[project_ids][]'
      assert_select 'input[name=?][value="2"]:not([checked])', 'tracker[project_ids][]'

      assert_select 'input[name=?][value=""][type=hidden]', 'tracker[project_ids][]'
    end

    test 'should render hidden tracker project ids for plain project' do
      project = Project.find(1)
      assert project.project_type_id.nil?
      tracker = Tracker.generate!
      project.trackers << tracker
      assert project.trackers.pluck(:id).include? tracker.id

      get edit_tracker_path(id: tracker.id)
      assert_response :success
      assert_select 'input[type=hidden][name=?][value=?]', 'tracker[project_ids][]', '1'
    end
  end
end
