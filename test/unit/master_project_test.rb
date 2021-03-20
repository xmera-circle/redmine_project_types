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

class MasterProjectTest < ActiveSupport::TestCase
  extend ProjectTypes::LoadFixtures

  fixtures :projects,
          :members, :member_roles, :roles, :users,
          :trackers, :projects_trackers, :issue_statuses,
          :project_types

  test 'should respond to project_type?' do
    assert master.respond_to? :project_type?
  end

  test 'should be a master project' do
    assert master.project_type?
  end

  test 'should find all master projects' do
    master
    assert_equal 1, MasterProject.list.count
  end

  private

  def master
    MasterProject.create(name: 'Name1', 
                        identifier: 'name1',
                        project_type_id: 1,
                        is_master: true)
  end
end

