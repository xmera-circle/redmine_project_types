# frozen_string_literal: true

#
# Redmine plugin for xmera called Project Types Plugin.
#
# Copyright (C) 2017-2023 Liane Hampe <liaham@xmera.de>, xmera Solutions GmbH.
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

class RelativesTest < ActiveSupport::TestCase
  include ProjectTypes::ProjectTypeCreator
  extend ProjectTypes::LoadFixtures

  fixtures :projects

  test 'should respond to all' do
    assert Relatives.new(project(id: 1)).respond_to? :all
  end

  test 'should respond to count' do
    assert Relatives.new(project(id: 1)).respond_to? :count
  end

  test 'should return nil project type' do
    assert_not Relatives.new(project(id: 1)).send :project_type
  end

  test 'should return project type' do
    find_project_type(id: 4)
    assert Relatives.new(project(id: 4)).send :project_type
  end

  private

  def project(id:, type: nil)
    project = Project.find(id)
    project.project_type_id = type
    project.save
    project
  end
end
