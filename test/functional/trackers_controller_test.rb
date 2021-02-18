# frozen_string_literal: true

# frozen_string_literal: true

#
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
  class TrackersControllerTest < ActionDispatch::IntegrationTest
    extend ProjectTypes::LoadFixtures
    include ProjectTypes::AuthenticateUser

    fixtures :projects, :versions, :users, :email_addresses, :roles, :members,
             :member_roles, :issues, :journals, :journal_details,
             :trackers, :projects_trackers, :issue_statuses,
             :enabled_modules, :enumerations, :boards, :messages,
             :attachments, :custom_fields, :custom_values, :time_entries,
             :wikis, :wiki_pages, :wiki_contents, :wiki_content_versions,
             :project_types,
             :enabled_project_type_modules

    def setup
      log_user('admin', 'admin')
    end

    test 'should assign tracker to project type and sync projects_tracker table' do
      tracker = Tracker.find(1)
      tracker.project_type_ids = [1, 3]
      ProjectType.find(1).project_ids = [1]
      ProjectType.find(2).project_ids = [2]
      ProjectType.find(3).project_ids = [3]
      put tracker_path(
        id: 1,
        tracker: { name: 'Renamed tracker',
                   project_type_ids: ['', '1', '2'] }
      )
      assert_redirected_to action: :index
      assert ProjectType.find(1).trackers.include? tracker
      assert ProjectType.find(2).trackers.include? tracker
      assert ProjectType.find(3).trackers.empty?
      assert Project.find(1).trackers.include? tracker
      assert Project.find(2).trackers.include? tracker
      assert Project.find(3).trackers.empty?
    end
  end
end
