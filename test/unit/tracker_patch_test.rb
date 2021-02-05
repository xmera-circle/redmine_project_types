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

class TrackerPatchTest < ActiveSupport::TestCase
  extend RedmineProjectTypes::LoadFixtures

  fixtures :projects, 
           :members, 
           :member_roles, 
           :roles, 
           :users,
           :trackers,
           :project_types
   
  def setup
    #
  end

  test 'should have and belong to many project_types' do
    assert association = Tracker.reflect_on_association(:project_types)
    sleep(2) # Sometimes the association is nil but when debugging it is o.k.
    assert_equal :project_types, association&.name
    assert_equal project_type_options, association&.options
  end

  test 'should not have safe project_ids attribute' do
    assert_not tracker(id: 1).safe_attribute? 'project_ids'
  end

  test 'should have safe project_type_ids attribute' do
    assert tracker(id: 1).safe_attribute? 'project_type_ids'
  end

  test 'should respond to add_projects_tracker' do
    assert tracker(id: 1).respond_to? :add_projects_tracker
  end

  test 'should respond to remove_projects_tracker' do
    assert tracker(id: 1).respond_to? :remove_projects_tracker
  end

  
  private

  def tracker(id:)
    Tracker.find(id.to_i)
  end

  def project_type_options
    Hash({ autosave: true,
           after_add: :add_projects_tracker,
           after_remove: :remove_projects_tracker })
  end
end
