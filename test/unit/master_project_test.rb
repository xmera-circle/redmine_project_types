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

  test 'should respond to of' do
    assert MasterProject.respond_to? :of
  end


  test 'should respond to master_project?' do
    assert master.respond_to? :master_project?, true
  end

  test 'should be a master project' do
    assert master.send :master_project?
  end

  test 'should create master parent' do
    assert master
    assert_equal 'Masterobjekte', master.name
  end

  private

  def master
    MasterProject.master_parent
  end

end

