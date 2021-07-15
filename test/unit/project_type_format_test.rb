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

class ProjectTypeFormatTest < ActiveSupport::TestCase
  include ProjectTypes::ProjectTypeCreator
  extend ProjectTypes::LoadFixtures

  fixtures :projects, :versions, :trackers,
           :roles, :users, :members, :member_roles, :issues,
           :issue_statuses, :issue_categories, :issue_relations, :workflows,
           :enumerations, :custom_fields, :custom_fields_trackers,
           :enabled_modules

  def setup
    find_project_type(id: 4)
    super
    User.current = nil
  end

  def test_create_project_type_master_field
    field = IssueCustomField.new(name: 'Master project',
                                 field_format: 'project_type_master')
    assert field.save!
  end

  def test_existing_project_type_master_values_should_be_valid
    field = IssueCustomField.create!(name: 'Master project',
                                     field_format: 'project_type_master',
                                     is_for_all: true,
                                     trackers: Tracker.all)
    project = Project.generate!
    master = ProjectType.find(4)
    issue = Issue.generate!(project_id: project.id, tracker_id: 1,
                            custom_field_values: { field.id => master.id })
    assert_include(
      [master.name, master.id.to_s],
      field.possible_custom_value_options(issue.custom_value_for(field))
    )
    assert issue.valid?
  end

  def test_not_existing_project_type_master_values_should_be_invalid
    field = IssueCustomField.create!(name: 'Master project',
                                     field_format: 'project_type_master',
                                     is_for_all: true,
                                     trackers: Tracker.all)
    project = Project.generate!
    master = Project.find(3)
    assert_raise 'Validation failed: Master project is not included in the list' do
      Issue.generate!(project_id: project.id, tracker_id: 1,
                      custom_field_values: { field.id => master.id })
    end
  end

  def test_possible_values_options_should_return_project_type_masters
    field = IssueCustomField.create!(name: 'Master project',
                                     field_format: 'project_type_master',
                                     is_for_all: true,
                                     trackers: Tracker.all)
    project = Project.find(1)
    expected = ProjectType.find(4).name

    assert_equal [expected], field.possible_values_options(project).map(&:first)
  end

  def test_query_filter_options_should_include_project_type_master
    field = IssueCustomField.create!(name: 'Master project',
                                     field_format: 'project_type_master',
                                     is_for_all: true,
                                     trackers: Tracker.all)
    master = ProjectType.find(4)
    query = IssueQuery.new(project: Project.find(1))
    assert_include master.name, field.query_filter_options(query)[:values].call.map(&:first)
  end
end
