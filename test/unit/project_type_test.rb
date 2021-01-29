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
           :project_types

  test "should not save project type without name" do
    project_type = ProjectType.new
    assert_not project_type.valid?
    assert_equal [:name], project_type.errors.keys
  end
  
  test "should not save two project types with identical names" do
    project_type = ProjectType.new(name: "name1")
    assert_not project_type.valid?
    assert_equal [:name], project_type.errors.keys
  end
  
  test "should order by position" do
    project_type1 = ProjectType.find(1)
    project_type2 = ProjectType.find(2)
    project_type3 = ProjectType.find(3)
    assert_equal 1, project_type3.position - project_type2.position
    assert_equal 1, project_type2.position - project_type1.position
  end

  test "should respond to is_public?" do
    project_type = ProjectType.find(1)
    assert project_type.respond_to? :is_public?
  end


  test "should respond to default_member_role" do
    project_type = ProjectType.find(1)
    assert project_type.respond_to? :default_member_role
  end
end
