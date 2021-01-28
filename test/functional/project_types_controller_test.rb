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
  include Redmine::I18n

  fixtures :projects, 
           :members, 
           :member_roles, 
           :roles, 
           :users, 
           :project_types,
           :projects_project_types
 
  test 'should get index' do
    log_user('admin', 'admin')
    get project_types_url
    assert_response :success
    assert_template "index"
  end
  
  test 'should get new' do
    log_user('admin', 'admin')
    get new_project_type_url
    assert_response :success
    assert_template "new"
  end
  
  test 'should get edit' do
    log_user('admin', 'admin')
    get edit_project_type_url(id: 1)
    assert_response :success
    assert_template "edit"
  end

  test 'should redirect after create' do
    log_user('admin', 'admin')
    assert_difference after_create do
      post project_types_url, params: project_type_create_params(defaults)
    end
    assert_redirected_to(controller: "project_types", action: "index")
  end

  test 'should update' do
    log_user('admin', 'admin')
    type_to_change = ProjectType.first
    patch project_type_url(type_to_change), params: project_type_update_params
    type_to_change.reload
    assert_equal 'changed', type_to_change.name
  end

  test "should delete when it has no projects" do
    log_user('admin', 'admin')
    post project_types_url, params: project_type_create_params(defaults)      
    assert_difference after_delete do
      delete "/project_types/#{ProjectType.last.id}", params: nil
    end
    assert_redirected_to(controller: "project_types", action: "index")
  end

  test "should not delete when it has projects" do
    log_user('admin', 'admin')
    assert_no_difference 'ProjectType.count' do
      delete '/project_types/1', params: nil
    end
    assert_equal 'Unable to delete project type due to related projects', flash[:error].to_s
  end

  private

  def project_type_create_params(associates)
    { project_type:
      { name: 'Lore ipsum',
        description: 'for testing',
        is_public: 0,
        default_user_role_id: 3,
        position: 4 } }.merge(associates)
  end

  def defaults 
    { project_types_default_module: { project_type_id: 1, name: ["","wiki", "documents"] },
      project_types_default_tracker: { project_type_id: 1, tracker_id: ["",1,2] } }
  end

  def after_create
    { ->{ ProjectType.count } => 1, 
      ->{ProjectTypesDefaultModule.count} => 2, 
      ->{ProjectTypesDefaultTracker.count} => 2 }
  end

  def project_type_update_params
     { project_type: { name: 'changed' } }
  end

  def after_delete
    { ->{ ProjectType.count } => -1, 
    ->{ProjectTypesDefaultModule.count} => -2, 
    ->{ProjectTypesDefaultTracker.count} => -2 }
  end  
end
