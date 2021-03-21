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
  class ProjectTypesControllerTest < ActionDispatch::IntegrationTest
    extend ProjectTypes::LoadFixtures
    include ProjectTypes::AuthenticateUser
    include ProjectTypes::CreateProjectType
    include Redmine::I18n

    fixtures :projects,
             :members, :member_roles, :roles, :users,
             :trackers, :projects_trackers, :issue_statuses,
             :project_types

    def teardown
      project_type = ProjectType.find_by_name('Lore ipsum')
      if project_type
        project_type.master&.delete
        project_type.delete
      end
    end
    
    test 'index by anonymous should redirect to login form' do
      User.anonymous
      get project_types_url
      assert_redirected_to '/login?back_url=http%3A%2F%2Fwww.example.com%2Fadmin%2Fproject_types'
    end

    test 'index by user should respond with 403' do
      log_user('jsmith', 'jsmith')
      get project_types_url
      assert_response 403
    end

    test 'should get index' do
      log_user('admin', 'admin')
      get project_types_url
      assert_response :success
      assert_template 'index'
    end

    test 'should delete when it has no projects' do
      log_user('admin', 'admin')
      post projects_url, params: project_type_create_params
      assert_redirected_to settings_project_path(ProjectType.projects.last.identifier)
      assert_equal 1, ProjectType.projects.count
      assert_difference 'ProjectType.projects.count', -1 do
        delete "/admin/project_types/#{ProjectType.projects.last.identifier}", params: { confirm: 1 }
      end
      assert_redirected_to(controller: 'project_types', action: 'index')
    end

    test 'should not delete when it has projects' do
      log_user('admin', 'admin')

      project_type = Project.find(2)
      project_type.is_master = true
      project_type.save

      project = Project.find(1)
      project.project_type_id = 2
      project.save

      assert_no_difference 'ProjectType.projects.count' do
        delete "/admin/project_types/#{ProjectType.projects.last.identifier}", params: nil
      end
      assert_match l(:text_project_type_destroy_confirmation), response.body
    end

    test 'should redirect to project types after archive and unarchive' do
      log_user('admin', 'admin')
      project_type = find_project_type(id: 2)
      post archive_project_type_path(project_type.identifier)
      assert_redirected_to project_types_path
      post unarchive_project_type_path(project_type.identifier)
      assert_redirected_to project_types_path
    end
    
    private


    def find_project_type(id:)
      project_type = Project.find(id)
      project_type.is_master = true
      project_type.save
      project_type
    end

    def project_type_create_params(attributes = {})
      { project:
        { name: 'Lore ipsum',
          description: 'for testing',
          identifier: 'lore-ipsum',
          is_master: true}.merge(attributes) }
    end

    def after_create_with_associates
      { -> { ProjectType.count } => 1 }
    end

    def after_delete_with_associates
      { -> { ProjectType.count } => -1 }
    end

    def after_create
      { -> { ProjectType.count } => 1 }
    end

    def project_type_update_params
      { project_type: { name: 'changed' } }
    end

  end
end
