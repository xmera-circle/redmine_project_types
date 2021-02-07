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

class IssueCustomFieldPatchTest < ActiveSupport::TestCase
  extend RedmineProjectTypes::LoadFixtures

  fixtures :projects, 
           :members, 
           :member_roles, 
           :roles, 
           :users,
           :trackers,
           :custom_fields_trackers,
           :custom_fields_projects,
           :project_types
   
  def setup
    #
  end

  # test 'should have and belong to many issue_custom_fields' do
  #   assert association = IssueCustomField.reflect_on_association(:issue_custom_fields)
  #   assert_equal :issue_custom_fields, association.name
  #   assert_equal :has_and_belongs_to_many, association.macro
  #   assert_equal issue_custom_field_options, association.options
  # end

  test 'should not have safe project_ids attribute' do
    assert_not issue_custom_field.safe_attribute? 'project_ids'
  end

  test 'should have safe project_type_ids attribute' do
    assert issue_custom_field.safe_attribute? 'project_type_ids'
  end

  test 'should respond to add_custom_field_projects' do
    assert issue_custom_field.respond_to? :add_custom_fields_projects
  end

  test 'should respond to remove_custom_field_projects' do
    assert issue_custom_field.respond_to? :remove_custom_fields_projects
  end

  
  private

  def issue_custom_field
    IssueCustomField.first
  end

  def issue_custom_field_options
    Hash({ autosave: true,
           after_add: :add_custom_field_projects,
           after_remove: :remove_custom_field_projects })
  end
end
