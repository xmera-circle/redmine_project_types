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

class ProjectTypeTest < ActiveSupport::TestCase
  include RedmineProjectTypes::LoadFixtures

  fixtures :projects, 
           :members, 
           :member_roles, 
           :roles, 
           :users, 
           :project_types

  test "should not save project type without name" do
    # note: enabled_module_names must be at least empty. Therefore, there is
    # an empty hidden field in the view.
    project_type = ProjectType.new(enabled_module_names: [])
    assert_not project_type.valid?
    assert_equal [:name], project_type.errors.keys
  end
  
  test "should not save two project types with identical names" do
    project_type = ProjectType.new(name: "name1", enabled_module_names: [])
    assert_not project_type.valid?
    assert_equal [:name], project_type.errors.keys
  end
  
  test "should order by position" do
    assert_equal 1, project_type(3).position - project_type(2).position
    assert_equal 1, project_type(2).position - project_type(1).position
  end

  test "should respond to is_public?" do
    assert project_type(1).respond_to? :is_public?
  end


  test "should respond to default_member_role" do
    assert project_type(1).respond_to? :default_member_role
  end

  test "should have safe_attributes" do
    assert_equal safe_attribute_names, project_type(1).safe_attribute_names
  end


  test "should have many projects" do
    association = ProjectType.reflect_on_association(:projects)
    assert_equal :projects, association.name
    assert_equal Hash({ autosave: true }), association.options
  end

  test "should have many enabled modules" do
    association = ProjectType.reflect_on_association(:enabled_modules)
    assert_equal :enabled_modules, association.name
    assert_equal enabled_modules_association, association.options
  end

  private

  def project_type(id)
    ProjectType.find(id.to_i)
  end

  def safe_attribute_names
    %w[name
      description
      identifier
      is_public
      default_member_role_id
      position
      enabled_module_names]
  end

  def enabled_modules_association
    Hash({ class_name: 'EnabledProjectTypeModule', dependent: :delete_all })
  end
end
