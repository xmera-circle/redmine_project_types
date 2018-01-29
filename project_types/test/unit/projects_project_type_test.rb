require File.expand_path('../../test_helper', __FILE__)



class ProjectsProjectTypeTest < ActiveSupport::TestCase
  # The fixtures method allows us to include fixtures from Redmine core's
  # test suite (for example, :issues, :roles, :users, :projects, and so on)
  fixtures :projects, :members, :member_roles, :roles, :users
  
  # plugin_fixtures: This is the method we monkey-patched into the various 
  # TestCase classes so that we could interact with Redmine's fixtures as 
  # well as our own custom fixtures.
  # The usage of plugin_fixtures requires some code in the plugins 
  # test_helper.rb
  #plugin_fixtures :project_types, :projects_project_types
  
  ProjectType::TestCase.create_fixtures(Redmine::Plugin.find(:project_types).directory + '/test/fixtures/', [:project_types, :projects_project_types])
  
  def setup
    @projects_type1 = ProjectsProjectType.new(:project_id => "4", :project_type_id => "10")
    @projects_type2 = ProjectsProjectType.new(:project_id => "4", :project_type_id => "20")
  end
    

  test "should not save two project types for a single project" do
    @projects_type1.save     
    assert !@projects_type2.save, "Saved a second project type for a single project."
  end
  
  test "different project types should not have the same set of projects" do
    first_project_set = ProjectType.find(1).projects
    second_project_set = ProjectType.find(2).projects
    
    assert_not_equal( first_project_set, second_project_set )
  end
  
  test "projects without project type should be nil" do
    project = Project.find(6)
    
    assert !project.projects_project_type
  end
  

  
    
  
end
