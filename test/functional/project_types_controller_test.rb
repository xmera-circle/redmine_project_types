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

class ProjectTypesControllerTest < ActionDispatch::IntegrationTest
  extend RedmineProjectTypes::LoadFixtures
  include RedmineProjectTypes::AuthenticateUser
  include RedmineProjectTypes::CreateProjectType
  include Redmine::I18n

  fixtures :projects,
           :members, :member_roles, :roles, :users,
           :trackers, :projects_trackers, :issue_statuses,
           :project_types

  test 'index by anonymous should redirect to login form' do
    User.anonymous
    get project_types_url
    assert_redirected_to '/login?back_url=http%3A%2F%2Fwww.example.com%2Fproject_types'
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

  test 'should get new' do
    log_user('admin', 'admin')
    get new_project_type_url
    assert_response :success
    assert_template 'new'
  end

  test 'should get edit' do
    log_user('admin', 'admin')
    get edit_project_type_url(id: 1)
    assert_response :success
    assert_template 'edit'
  end

  test 'should redirect after create' do
    log_user('admin', 'admin')
    assert_difference after_create do
      post project_types_url, params: project_type_create_params(empty_modules)
    end
    assert_redirected_to(controller: 'project_types', action: 'index')
  end

  test 'should update' do
    log_user('admin', 'admin')
    type_to_change = ProjectType.first
    patch project_type_url(type_to_change), params: project_type_update_params
    type_to_change.reload
    assert_equal 'changed', type_to_change.name
  end

  test 'should delete when it has no projects' do
    log_user('admin', 'admin')
    post project_types_url, params: project_type_create_params(empty_modules)
    assert_redirected_to(controller: 'project_types', action: 'index')
    assert_difference after_delete do
      delete "/project_types/#{ProjectType.last.id}", params: nil
    end
    assert_redirected_to(controller: 'project_types', action: 'index')
  end

  test 'should not delete when it has projects' do
    log_user('admin', 'admin')
    project = Project.find(1)
    project.project_type_id = 1
    project.save
    assert_no_difference 'ProjectType.count' do
      delete project_type_path(id: 1)
    end
    assert_equal 'Cannot delete project type due to related projects.', flash[:error].to_s
  end

  test 'should save and delete associates' do
    log_user('admin', 'admin')
    assert_difference after_create_with_associates do
      post project_types_url, params: project_type_create_params(associates)
    end
    assert_redirected_to(controller: 'project_types', action: 'index')
    assert_difference after_delete_with_associates do
      delete "/project_types/#{ProjectType.last.id}", params: nil
    end
    assert_redirected_to(controller: 'project_types', action: 'index')
  end

  private

  def project_type_create_params(associates)
    { project_type:
      { name: 'Lore ipsum',
        description: 'for testing',
        is_public: 0,
        default_member_role_id: 3,
        position: 4 }.merge(associates) }
  end

  def associates
    { enabled_module_names: ['', 'issue_tracking'],
      tracker_ids: ['', 1, 2],
      issue_custom_field_ids: ['', 1, 2],
      project_custom_field_ids: ['', 3] }
  end

  def after_create_with_associates
    { -> { ProjectType.count } => 1,
      -> { ProjectType.last.enabled_modules.count } => 1,
      -> { ProjectType.last.trackers.count } => 2,
      -> { ProjectType.last.issue_custom_field_ids.count } => 2,
      -> { ProjectType.last.project_custom_field_ids.count } => 1 }
  end

  def after_delete_with_associates
    { -> { ProjectType.count } => -1,
      -> { ProjectType.last.enabled_modules.count } => -1,
      -> { ProjectType.last.trackers.count } => -2,
      -> { ProjectType.last.issue_custom_field_ids.count } => -2,
      -> { ProjectType.last.project_custom_field_ids.count } => -1 }
  end

  def empty_modules
    { enabled_module_names: [''] }
  end

  def after_create
    { -> { ProjectType.count } => 1 }
  end

  def project_type_update_params
    { project_type: { name: 'changed' } }
  end

  def after_delete
    { -> { ProjectType.count } => -1 }
  end
end
