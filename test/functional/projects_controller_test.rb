# frozen_string_literal: true

# frozen_string_literal: true

#
# Redmine plugin for xmera called Project Types Plugin.
#
# Copyright (C) 2017 - 2022 Liane Hampe <liaham@xmera.de>, xmera.
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

module ProjectTypes
  class ProjectsControllerTest < ActionDispatch::IntegrationTest
    extend ProjectTypes::LoadFixtures
    include ProjectTypes::AuthenticateUser
    include ProjectTypes::ProjectTypeCreator

    fixtures :projects, :versions, :users, :email_addresses, :roles, :members,
             :member_roles, :issues, :journals, :journal_details,
             :trackers, :projects_trackers, :issue_statuses,
             :enabled_modules, :enumerations, :boards, :messages,
             :attachments, :custom_fields, :time_entries,
             :wikis, :wiki_pages, :wiki_contents, :wiki_content_versions

    def setup
      #
    end

    test 'should create project with project type by non admin user' do
      project_type = ProjectType.create(name: 'Change Project',
                                        identifier: 'change-project',
                                        is_project_type: true)

      version_name = 'Kick Off'
      project_type.versions << Version.create(name: version_name)
      project_type.tracker_ids = [1, 2]

      assert_equal 1, ProjectType.masters.count
      assert_equal 7, Project.count

      log_user('jsmith', 'jsmith')
      assert_difference 'Project.count' do
        post projects_path, params: {
          project: {
            name: 'blog',
            description: 'weblog',
            homepage: 'http://weblog',
            identifier: 'blog',
            is_public: true,
            project_type_id: project_type.id,
            # this attribute should be automatically set to false
            is_project_type: true
          }
        }
      end
      assert_redirected_to settings_project_path(id: 'blog')

      new_project = Project.last
      assert_equal project_type.id, new_project.project_type_id
      assert new_project.versions.map(&:name).include? version_name
      assert_equal [], new_project.tracker_ids - [1, 2]
    end

    test 'should create project with project type by admin' do
      project_type = ProjectType.create(name: 'Change Project',
                                        identifier: 'change-project',
                                        is_project_type: true)

      version_name = 'Kick Off'
      project_type.versions << Version.create(name: version_name)
      project_type.tracker_ids = [1, 2]

      assert_equal 1, ProjectType.masters.count
      assert_equal 7, Project.count

      log_user('admin', 'admin')

      assert_difference 'Project.count' do
        post projects_path, params: {
          project: {
            name: 'blog',
            description: 'weblog',
            homepage: 'http://weblog',
            identifier: 'blog',
            is_public: true,
            project_type_id: project_type.id
          }
        }
      end
      assert_redirected_to settings_project_path(id: 'blog')

      new_project = Project.last
      assert_equal project_type.id, new_project.project_type_id
      assert new_project.versions.map(&:name).include? version_name
      assert_equal [], new_project.tracker_ids - [1, 2]
    end

    test 'should create project without project type' do
      log_user('admin', 'admin')

      assert_difference 'Project.count' do
        post projects_path, params: {
          project: {
            name: 'Default Project',
            description: 'Default project without project type',
            homepage: 'http://default-project',
            identifier: 'default-project',
            is_public: false,
            project_type_id: nil,
            is_project_type: false
          }
        }
      end
      assert_redirected_to settings_project_path(id: 'default-project')
      assert_not Project.last.project_type_id
    end

    test 'should create project with required custom field' do
      project_type3 = project_type(id: 3)
      _, cf3_id = prepare_project_type_custom_fields

      assert ProjectCustomField.find(cf3_id).is_required
      assert project_type3.project_custom_field_ids.include? cf3_id
      log_user('admin', 'admin')
      assert_difference 'Project.count' do
        post projects_path, params: {
          project: {
            name: 'Project1',
            identifier: 'project1',
            project_type_id: '3',
            is_project_type: false
          }
        }
      end
      project1 = Project.last.reload
      assert_redirected_to settings_project_path(id: project1.identifier)

      assert_equal 'Project1', project1.name
      assert_equal nil, project1.custom_field_value(cf3_id)
      assert_equal [cf3_id], project1.project_custom_field_ids
    end

    test 'should get copy for project type master' do
      orig = project_type(id: 4)
      log_user('admin', 'admin')
      get copy_project_path(id: orig.id)
      assert_response :success

      assert_select 'textarea[name=?]', 'project[description]', text: orig.description
      assert_select 'input[name=?][value=?]', 'project[enabled_module_names][]', 'issue_tracking', 1
    end

    private

    def project_attributes
      { project: { name: 'New project with project type', project_type_id: 1 } }
    end

    def project(id:, type:)
      project = Project.find(id.to_i)
      project.project_type_id = type
      project.save
      project
    end

    def project_type(id:)
      find_project_type(id: id)
    end

    def project_custom_field(id:)
      ProjectCustomField.find(id.to_i)
    end

    def prepare_project_type_custom_fields
      custom_field2 = ProjectCustomField.generate! field_format: 'list', possible_values: %w[Foo Bar], multiple: true
      custom_field3 = ProjectCustomField.generate! field_format: 'string', is_required: true
      project_type2 = project_type(id: 2)
      project_type3 = project_type(id: 3)
      project_type2.update_attribute :project_custom_field_ids, [custom_field2.id]
      project_type3.update_attribute :project_custom_field_ids, [custom_field3.id]
      [custom_field2.id, custom_field3.id]
    end
  end
end
