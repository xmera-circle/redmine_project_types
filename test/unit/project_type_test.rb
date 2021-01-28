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

class ProjectTypeTest < ActiveSupport::TestCase
  include RedmineProjectTypes::LoadFixtures

  fixtures :projects, 
           :members, 
           :member_roles, 
           :roles, 
           :users, 
           :project_types,
           :projects_project_types

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
