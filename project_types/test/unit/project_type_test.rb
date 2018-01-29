require File.expand_path('../../test_helper', __FILE__)



class ProjectTypeTest < ActiveSupport::TestCase
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

  test "should not save project type without name" do
    projecttype = ProjectType.new
    assert !projecttype.save, "Saved the project type without a name."
  end
  
  test "should not save two project types with identical names" do
    projecttype1 = ProjectType.new(:name => "FirstProjectType")
    projecttype1.save
    projecttype2 = ProjectType.new(:name => "FirstProjectType")
    assert !projecttype2.save, "Saved the project type with an already existing project type name."
  end
  
  test "should order by position" do
    projecttype1 = ProjectType.find(1)
    projecttype2 = ProjectType.find(2)
    projecttype3 = ProjectType.find(3)
    assert_equal 1, projecttype3.position - projecttype2.position
    assert_equal 1, projecttype2.position - projecttype1.position
  end
  
end
