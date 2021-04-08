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
  include ProjectTypes::ProjectTypeCreator

  extend ProjectTypes::LoadFixtures

  fixtures :projects

  test 'should respond to projects' do
    assert ProjectType.respond_to? :projects
  end

  test 'should have many relatives' do
    association = ProjectType.reflect_on_association(:relatives)
    assert_equal :relatives, association.name
    assert_equal :has_many, association.macro
    assert_equal relatives_options, association&.options
  end

  test 'should nullify projects project type when deleting a project type' do
    project_type4 = create_project_type(name: 'to be deleted')
    project1 = project(id: 1, type: project_type4.id)
    assert_equal project_type4.id, project1.project_type_id
    assert project_type4.destroy
    assert_not ProjectType.find_by(id: project_type4.id)
    project1.reload
    assert_not project1.project_type_id
  end

  private

  def relatives_options
    Hash({ class_name: 'Project',
           dependent: :nullify,
           inverse_of: :project_type })
  end

  def project(id:, type: nil)
    project = Project.find(id)
    project.project_type_id = type
    project.save
    project
  end
end
