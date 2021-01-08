# Redmine plugin for xmera called Project Types Plugin.
#
# Copyright (C) 2017-21 Liane Hampe <liaham@xmera.de>. xmera.
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

class ProjectsProjectTypeTest < ActiveSupport::TestCase
  extend RedmineProjectTypes::LoadFixtures

  fixtures :projects, 
           :members, 
           :member_roles, 
           :roles, 
           :users, 
           :project_types,
           :projects_project_types
   
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
