# Redmine plugin for xmera called Project Types Plugin.
#
# Copyright (C) 2017-19 Liane Hampe <liane.hampe@xmera.de>.
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

require File.expand_path('../../test_helper', __FILE__)

class ProjectTypesControllerTest < ActionController::TestCase
  
 include Redmine::I18n

 fixtures :projects, :members, :member_roles, :roles, :users

 ProjectType::TestCase.create_fixtures(Redmine::Plugin.find(:project_types).directory + '/test/fixtures/', [:project_types, :projects_project_types])
 
  # Default setting with admin user
  def setup
    User.current = nil
    @request.session[:user_id] = 1 # admin
    @project = Project.find(1)
    @project_type = ProjectType.find(1)
  end
 
 
  test "should get index" do
    get :index
    assert_response :success
    assert_template "index"
  end
  
  test "should get new" do
    get :new
    assert_response :success
    assert_template "new"
  end
  
  test "should get edit" do
    get :edit,:id => @project_type.id
    assert_response :success
    assert_template "edit"
  end

  test "should redirect create" do
    assert_difference('ProjectType.count', 1) do
      post :create, project_type: { name: "Lorem ipsum",
                                    description: "abcdefg",
                                    is_public: 0, 
                                    default_user_role_id: 3,
                                    position: 4},
                    project_types_default_module: { project_type_id: 1,
                                                    name: ["","wiki", "documents"]},
                    project_types_default_tracker: { project_type_id: 1,
                                                     tracker_id: ["",1,2]}
    end
    assert_equal 2, ProjectTypesDefaultModule.count
    assert_equal 2, ProjectTypesDefaultTracker.count
    assert_redirected_to(controller: "project_types", action: "index")
  end
  
  test "should update ProjectType" do
    
    name_new = "new name"
    description_new = "-"
    is_public_new = true
    default_user_role_id_new = 4
    position_new = 4
    
    
    project_type = ProjectType.create(name: "name", 
                                   description: "abc", 
                                   is_public: 0, 
                                   default_user_role_id: 3, 
                                   position: 1)
    
    
    patch :update, :id => project_type.id, project_type: { id: project_type.id, 
                                                           name: name_new, 
                                                           description: description_new, 
                                                           is_public: is_public_new, 
                                                           default_user_role_id: default_user_role_id_new, 
                                                           position: position_new }
  
    assert_equal name_new, project_type.reload.name
    assert_equal description_new, project_type.reload.description
    assert_equal is_public_new, project_type.reload.is_public
    assert_equal default_user_role_id_new, project_type.reload.default_user_role_id
    assert_equal position_new, project_type.reload.position
    assert_redirected_to(controller: "project_types", action: "index")
  end
  
  test "should update ProjectType (without position) and ProjectTypeDefaultModule" do
    
    name_new = "new name"
    description_new = "-"
    is_public_new = true
    default_user_role_id_new = 4
    modulename1 = ""
    modulename2 = "wiki"
    modulename3 = "documents"
    trackerid1 = ""
    trackerid2 = 1
    trackerid3 = 2
    
    
    project_type = ProjectType.create(name: "name", 
                                   description: "abc", 
                                   is_public: 0, 
                                   default_user_role_id: 3, 
                                   position: 1)
    

    patch :update, :id => project_type.id, project_type: { id: project_type.id, 
                                                           name: name_new, 
                                                           description: description_new, 
                                                           is_public: is_public_new, 
                                                           default_user_role_id: default_user_role_id_new},
                                           project_types_default_module: { project_type_id: project_type.id,
                                                                           name: [modulename1,modulename2, modulename3]},
                                           project_types_default_tracker: { project_type_id: project_type.id,
                                                     tracker_id: [trackerid1,trackerid2,trackerid3]}
  
    assert_equal name_new, project_type.reload.name
    assert_equal description_new, project_type.reload.description
    assert_equal is_public_new, project_type.reload.is_public
    assert_equal default_user_role_id_new, project_type.reload.default_user_role_id
    assert_equal 2, ProjectTypesDefaultModule.where(project_type_id: project_type.id).count
    assert_equal 2, ProjectTypesDefaultTracker.where(project_type_id: project_type.id).count
    assert ProjectTypesDefaultModule.find_by(name: modulename2), "modul 2 is missing"
    assert ProjectTypesDefaultModule.find_by(name: modulename3), "modul 3 is missing"
    assert ProjectTypesDefaultTracker.find_by(tracker_id: trackerid2), "tracker 2 is missing"
    assert ProjectTypesDefaultTracker.find_by(tracker_id: trackerid3), "tracker 3 is missing"
    assert_redirected_to(controller: "project_types", action: "index")
  end
  
  test "should delete ProjectType when it has no projects" do
    project_type = ProjectType.create!(name: "name", 
                                   description: "abc", 
                                   is_public: 0, 
                                   default_user_role_id: 3, 
                                   position: 1)
                                   
    ProjectTypesDefaultModule.create(project_type_id: project_type.id, name: "wiki")
    ProjectTypesDefaultTracker.create(project_type_id: project_type.id, tracker_id: 1)                                                                   
    
    assert_equal 4, ProjectType.count, "The project type was not created."
    assert_equal 1, ProjectTypesDefaultModule.count
    assert_equal 1, ProjectTypesDefaultTracker.count
    
    assert_difference('ProjectType.count', -1) do
      delete :destroy, :id => project_type.id
    end
    assert_equal 0, ProjectTypesDefaultModule.count, "Modules are not deleted"
    assert_equal 0, ProjectTypesDefaultTracker.count, "Trackers are not deleted"
    assert_redirected_to(controller: "project_types", action: "index")
  end
  
  test "should not delete ProjectType when it has projects" do
    assert_no_difference 'ProjectType.count' do
      delete :destroy, :id => 1
    end
    assert_equal 'Unable to delete project type due to related projects', flash[:error].to_s
  end
 
end
