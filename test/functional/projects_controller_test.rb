# frozen_string_literal: true

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

module ProjectTypes
  class ProjectsControllerTest < ActionDispatch::IntegrationTest
    extend ProjectTypes::LoadFixtures
    include ProjectTypes::AuthenticateUser

    fixtures :projects, :versions, :users, :email_addresses, :roles, :members,
             :member_roles, :issues, :journals, :journal_details,
             :trackers, :projects_trackers, :issue_statuses,
             :enabled_modules, :enumerations, :boards, :messages,
             :attachments, :custom_fields, :time_entries,
             :wikis, :wiki_pages, :wiki_contents, :wiki_content_versions,
             :project_types,
             :enabled_project_type_modules

    def setup
      log_user('admin', 'admin')
    end

    test 'should create project with project type' do
      skip
      assert_difference 'Project.count' do
        post projects_path, params: {
          project: {
            name: 'blog',
            description: 'weblog',
            homepage: 'http://weblog',
            identifier: 'blog',
            is_public: true,
            project_type_id: 1
          }
        }
      end
      assert_redirected_to settings_project_path(id: 'blog')
      assert_equal 1, Project.last.project_type_id
      assert_not Project.last.is_public?
    end

    ##
    # When changing the project type all other dependend fields will remain.
    # That is, they will be submitted and flow through all validations.
    # Especially, when there is a required custom field, the change will
    # cause validation errors.
    #
    # If this test passes, then the ProjectPatch#revise_project_type_dependencies
    # is working properly.
    #
    #
    test 'should ignore project custom fields not belonging to changed project type' do
      skip
      project1 = project(id: 1, type: 1)
      cf_id_project1, cf_id_project2 = prepare_project_type_custom_fields

      # Change project type to 2 where the custom field is required
      patch project_path(project1),
            params: { project: { id: '1',
                                 project_type_id: '2',
                                 # This needs to be the cf of previous project_type (1)
                                 custom_field_values: { "#{cf_id_project1}": '' } } }
      assert :success
      assert_equal 2, project1.reload.project_type_id

      # Change project type to 1 where the custom field is not required
      patch project_path(project1),
            params: { project: { id: '1',
                                 project_type_id: '1',
                                 # This needs to be the cf of previous project_type (2)
                                 custom_field_values: { "#{cf_id_project2}": '' } } }
      assert :success
      assert_equal 1, project1.reload.project_type_id
    end

    test 'should save project with changing custom fields' do
      skip
      project2 = project(id: 2, type: 2)
      _, cf_id_project2 = prepare_project_type_custom_fields
      patch project_path(project2),
            params: { project: { id: '1',
                                 project_type_id: '2',
                                 custom_field_values: { "#{cf_id_project2}": 'has changed' } } }
      assert :success
      assert_equal ['has changed'], project2.reload.custom_field_values.map(&:to_s)
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
      ProjectType.find(id.to_i)
    end

    def project_custom_field(id:)
      ProjectCustomField.find(id.to_i)
    end

    def prepare_project_type_custom_fields
      # custom_field3 = project_custom_field(id: 3)
      # custom_field3.update_attribute :is_required, true
      custom_field1 = ProjectCustomField.generate! field_format: 'list', possible_values: %w[Foo Bar], multiple: true
      custom_field2 = ProjectCustomField.generate! field_format: 'string', is_required: true
      project_type1 = project_type(id: 1)
      project_type2 = project_type(id: 2)
      project_type1.update_attribute :project_custom_field_ids, [custom_field1.id]
      project_type2.update_attribute :project_custom_field_ids, [custom_field2.id]
      [custom_field1.id, custom_field2.id]
    end
  end
end
