require File.expand_path('../../test_helper', __FILE__)

class ProjectsControllerPatchTest < ActionController::TestCase

 fixtures :projects, :members, :member_roles, :roles, :users

 #plugin_fixtures :project_types, :projects_project_types
 
 ProjectType::TestCase.create_fixtures(Redmine::Plugin.find(:project_types).directory + '/test/fixtures/', [:project_types, :projects_project_types])
 
 # Default setting
  def setup
    @controller = ProjectsController.new
    @request.session[:user_id] = nil
    Setting.default_language = 'en'
  end
 
 
  test "should have project type field in new projects" do
    @request.session[:user_id] = 1 # admin
    get :new
    assert_response :success
    assert_select '#project_projects_project_type_attributes_project_type_id'
  end
  
  test "should have project type field in projects setting" do
    @request.session[:user_id] = 1 # admin
    get :settings, :id => 1
    assert_response :success
    assert_select '#project_projects_project_type_attributes_project_type_id'
  end 
  
  test "#create should set project type default values" do
   @request.session[:user_id] = 1 # admin
   assert_difference 'Project.count' do 
      post :create, project: { name: "blog",
                               identifier: "blog",
                    projects_project_type_attributes: {
                               project_type_id: 2        
                              }}
      assert_redirected_to '/projects/blog/settings'
    end
    project_type = ProjectType.find(2)
    project = Project.find_by_name('blog')
    assert_equal true, project.projects_project_type.present? 
    assert_equal true, project.projects_project_type.project_type_id.present?
    assert_equal 2, project.projects_project_type.project_type.id
    assert_equal project_type.is_public, project.is_public?
    assert_equal ProjectTypesDefaultTracker.where(project_type_id: 1).pluck(:tracker_id), project.trackers.map(&:id).sort
    assert_equal ProjectTypesDefaultModule.where(project_type_id: 1).pluck(:name), project.reload.enabled_module_names.sort
  end
  
  test "#create by non-admin user should add default member" do
    Role.non_member.add_permission! :add_project
    @request.session[:user_id] = 9
    post :create, project: { name: "blog",
                             identifier: "blog",
                  projects_project_type_attributes: {
                             project_type_id: 2        
                           }}
    project_type = ProjectType.find(2)
    project = Project.find_by_name('blog')
    user = User.find(9)
    assert user.member_of?(project)
    assert_equal project_type.default_user_role_id, MemberRole.find_by(member_id: user.members.find_by(project_id: project.id).id).role_id
  end
    
  test "#create by admin user should not add default member" do
    @request.session[:user_id] = 1 # admin
    post :create, project: { name: "blog",
                             identifier: "blog",
                  projects_project_type_attributes: {
                             project_type_id: 2        
                           }}
    project_type = ProjectType.find(2)
    project = Project.find_by_name('blog')
    user = User.find(1)
    assert !user.member_of?(project)
  end
  
  test "create a new projects project type" do
   @request.session[:user_id] = 1 # admin
   assert_difference('ProjectsProjectType.count',1) do
     patch :update, :id => 4, project: { 
                    projects_project_type_attributes: { project_id: 4,
                               project_type_id: 1        
                             }}
     assert_redirected_to '/projects/subproject2/settings'
   end
 end
 
  test "delete a project should delete the respective projects project type" do
   @request.session[:user_id] = 1 # admin
   assert ProjectsProjectType.find_by(project_id: 1)
   assert_difference('Project.count',-5) do
     delete :destroy, :id => 1, :confirm => 1
     assert_redirected_to admin_projects_path #'/admin/projects'
   end
   assert_nil Project.find_by(id: 1)
   assert_nil ProjectsProjectType.find_by(project_id: 1)
 end
end
