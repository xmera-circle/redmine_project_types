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

class ProjectsControllerTest < ActionDispatch::IntegrationTest
  extend RedmineProjectTypes::LoadFixtures
  include RedmineProjectTypes::AuthenticateUser

  fixtures :projects, :versions, :users, :email_addresses, :roles, :members,
           :member_roles, :issues, :journals, :journal_details,
           :trackers, :projects_trackers, :issue_statuses,
           :enabled_modules, :enumerations, :boards, :messages,
           :attachments, :custom_fields, :custom_values, :time_entries,
           :wikis, :wiki_pages, :wiki_contents, :wiki_content_versions,
           :project_types,
           :projects_project_types

  def setup
    log_user('admin', 'admin')
  end

  test 'should create project with project type' do
    assert_difference 'Project.count' do
      post projects_url,
           params: project_params(projects_project_type_attributes)
    end
    assert_redirected_to '/projects/blog/settings'
    assert_equal 1, Project.last.projects_project_type.project_type_id
  end

  private

  def project_params(associate)
    { project:
      { name: 'blog',
        description: 'weblog',
        homepage: 'http://weblog',
        identifier: 'blog',
        is_public: 1 }.merge(associate) }
  end

  def projects_project_type_attributes
    { projects_project_type_attributes: { project_type_id: 1 } }
  end
end
