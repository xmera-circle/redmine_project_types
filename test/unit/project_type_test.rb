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
  extend ProjectTypes::LoadFixtures

  fixtures :projects,
           :members, :member_roles, :roles, :users,
           :trackers, :projects_trackers, :issue_statuses,
           :project_types

  test 'should not save project type without name' do
    project_type = ProjectType.new
    assert_not project_type.valid?
    assert_equal [:name], project_type.errors.keys
  end

  test 'should not save two project types with identical names' do
    project_type = ProjectType.new(name: 'name1')
    assert_not project_type.valid?
    assert_equal [:name], project_type.errors.keys
  end

  test 'should allow only one project type to be marked as is_master_parent' do
    project_type = project_type(2)
    assert_not project_type.update_attributes(is_master_parent: true)
    assert_equal [:is_master_parent], project_type.errors.keys
  end

  test 'should order by position' do
    assert_equal 1, project_type(3).position - project_type(2).position
    assert_equal 1, project_type(2).position - project_type(1).position
  end

  test 'should respond to is_public?' do
    assert project_type(1).respond_to? :is_public?
  end

  test 'should respond to master_parent' do
    assert ProjectType.respond_to? :master_parent
  end

  test 'should have safe_attributes' do
    # The difference is a more stable criteria since a longer list on the right
    # does not compromise the minimum requirement on the left.
    # A longer list occurs when the :redmine_project_types_relations plugin
    # is loaded.
    assert_equal [], safe_attribute_names - project_type(1).safe_attribute_names
  end

  test 'should has_one master project' do
    association = ProjectType.reflect_on_association(:master)
    assert_equal :master, association.name
    assert_equal :has_one, association.macro
    assert_equal master_association, association.options
  end

  test 'should know its master parent project' do
    # Trigger update process in order to create the master parent
    changed_name = 'Update name1'
    type = project_type(1)
    type.name = changed_name
    type.save
    assert_equal MasterProject, ProjectType.master_parent.class
  end

  test 'should create master for new project type' do
    name = 'New Project Type'
    new_project_type = ProjectType.create(name: name)
    assert_equal name, new_project_type.master.name
  end

  test 'should update master of existing project type' do
    changed_name = 'Changed name1'
    type = project_type(1)
    type.name = changed_name
    type.save
    assert_equal changed_name, type.master.name
  end

  test 'should not save project_type if master project identifier exists' do
    name = 'Subproject2'
    assert_raise(ActiveRecord::RecordInvalid) { ProjectType.create(name: name) }
    assert_not ProjectType.find_by(name: name)
  end

  test 'should have many projects' do
    association = ProjectType.reflect_on_association(:projects)
    assert_equal :projects, association.name
    assert_equal :has_many, association.macro
  end

  private

  def project_type(id)
    ProjectType.find(id.to_i)
  end

  def safe_attribute_names
    %w[name
       description
       position
       is_master_parent]
  end

  def master_association
    Hash({ class_name: 'MasterProject',
           inverse_of: :project_type,
           autosave: true })
  end
end
