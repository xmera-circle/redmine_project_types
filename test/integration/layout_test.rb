# Redmine plugin for xmera called Project Types Plugin.
#
#  Copyright (C) 2017-18 Liane Hampe <liane.hampe@xmera.de>
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
require File.expand_path("#{File.dirname(__FILE__)}/../load_fixtures")

class LayoutTest < Redmine::IntegrationTest
  include Redmine::I18n
  include RedmineProjectTypes::LoadFixtures

  fixtures :projects, :trackers, :issue_statuses, :issues,
           :enumerations, :users, :issue_categories,
           :projects_trackers,
           :roles,
           :member_roles,
           :members,
           :enabled_modules,
           :custom_fields, :custom_values,
           :custom_fields_projects, :custom_fields_trackers,
           :project_types,
           :projects_project_types,
           :project_types_default_trackers,
           :project_types_default_modules
  
  def test_existence_of_project_type_field
    log_user('jsmith', 'jsmith')
    project = Project.find(1)
    get settings_project_path(project)
    assert_response :success
    assert_select '#project_projects_project_type_attributes_project_type_id', 1
  end

  def test_non_existence_of_project_selection_for_custom_fields
    log_user('admin', 'admin')
    get edit_custom_field_path(id: 1)
    assert_response :success
    assert_select '#custom_field_project_ids', 0
  end
end