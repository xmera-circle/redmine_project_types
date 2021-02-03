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

class ProjectPatchTest < ActiveSupport::TestCase
  extend RedmineProjectTypes::LoadFixtures

  fixtures :projects, 
           :members, 
           :member_roles, 
           :roles, 
           :users, 
           :project_types
   
  def setup
    #
  end

  test 'should belong_to project_type' do
    assert association = Project.reflect_on_association(:project_type)
    assert_equal :project_type, association.name
  end

  test 'should have many project_type_modules' do
    assert association = Project.reflect_on_association(:project_type_modules)
    assert_equal :project_type_modules, association.name
    assert_equal module_options, association.options
  end

  test "should respond to synchronize_modules" do
    assert project(id: 1).respond_to? :synchronize_modules
  end

  test 'should have safe project_type_id attribute' do
    assert project(id: 1).safe_attribute? 'project_type_id'
  end

  test 'should not have safe is_public attribute' do
    assert_not project(id: 1).safe_attribute? 'is_public'
  end

  test 'should not have safe enabled_module_names attribute' do
    assert_not project(id: 1).safe_attribute? 'enabled_module_names'
  end
    
  test 'projects without project type should be nil' do
    assert !project(id: 6).project_type_id
  end

  test 'default_member_role should not exist without project type' do
    assert_equal project_type(1).default_member_role, 
                 project(id: 1, type_id: 1).default_member_role
    assert_not project(id: 2).default_member_role
  end

  test 'enabled_module_names should sync when changed in project type' do
    new_project = create_project_with_project_type('First test project', 2)
    assert_equal Setting.default_projects_modules, new_project.enabled_module_names
    project_type(2).disable_module! :wiki
    assert_equal Setting.default_projects_modules-[:wiki], new_project.enabled_module_names
  end

  test 'should create wiki when wiki module enabled first time' do
    new_project = create_project_with_project_type('Second test project', 2)
    assert Wiki.find_by(project_id: new_project.id)
  end

  test 'create new project with project type' do
    assert_difference 'Project.count' do
      new_project = create_project_with_project_type('Second test project', 3)
      assert_equal 3, new_project.project_type_id
    end 
  end

  private

  def module_options
    Hash({ class_name: 'EnabledProjectTypeModule',
           foreign_key: :project_type_id,
           through: :project_type,
           source: :enabled_modules})
  end

  def create_project_with_project_type(name, project_type_id)
    attrs = { name: name,
              identifier: name.downcase.gsub(' ', '_'),
              project_type_id: project_type_id }
    project = Project.create(attrs)
    project.save!
    project
  end

  def project(id:, type_id: nil)
    project = Project.find(id.to_i)
    project.project_type_id = type_id
    project.save
    project
  end

  def project_type(id)
     ProjectType.find(id.to_i)
  end
end
