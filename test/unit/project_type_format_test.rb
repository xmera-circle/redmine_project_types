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

class ProjectTypeFormatTest < ActiveSupport::TestCase
  include ProjectTypes::ProjectTypeCreator
  extend ProjectTypes::LoadFixtures

  fixtures :projects, :versions, :trackers, :projects_trackers,
           :roles, :users, :members, :member_roles, :issues,
           :issue_statuses, :issue_categories, :issue_relations, :workflows,
           :enumerations, :custom_fields, :custom_fields_trackers,
           :enabled_modules

  def setup
    @master4 = find_project_type(id: 4)
    @master6 = find_project_type(id: 6)
    @project1 = Project.find(1)
    @project1.update_attribute(:project_type_id, 4)
    @field = IssueCustomField.new(name: 'Master project 1',
                                  field_format: 'project_type_master',
                                  multiple: true,
                                  additional_projects: '4',
                                  is_for_all: true,
                                  trackers: Tracker.all)
    super
    User.current = nil
  end

  def test_create_project_type_master_field
    assert @field.save!
  end

  def test_existing_project_type_master_values_should_be_valid
    @field.save!
    project = Project.generate!

    issue = Issue.generate!(project_id: project.id, tracker_id: 1)
    issue.custom_field_values = { @field.id => [@master6.id, @project1.id] }
    issue.save!

    assert_include(
      [@master6.name, @master6.id.to_s],
      @field.possible_custom_value_options(issue.custom_value_for(@field))
    )

    assert_include(
      [@project1.name, @project1.id.to_s],
      @field.possible_custom_value_options(issue.custom_value_for(@field))
    )
    assert issue.valid?
  end

  def test_not_existing_project_type_master_values_should_be_invalid
    @field.save!
    project = Project.find(2)
    issue = Issue.generate!(project_id: project.id, tracker_id: 1)
    issue.custom_field_values = { @field.id => [99] }
    assert_raise 'Validation failed: Master project is not included in the list' do
      issue.save!
    end
  end

  def test_possible_values_options_should_return_project_type_masters
    expected = ['', @master6.name, @master4.name, @project1.name]
    assert_equal expected, @field.possible_values_options(@field).map(&:first)
  end

  def test_query_filter_options_should_include_project_type_master
    @field.save!
    query = IssueQuery.new(project: Project.find(1))
    assert_include @master4.name, @field.query_filter_options(query)[:values].call.map(&:first)
  end
end
