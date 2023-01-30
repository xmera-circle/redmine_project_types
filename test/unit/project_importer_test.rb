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

module ProjectTypes
  class ProjectImporterTest < UnitTest
    fixtures :projects, :members, :member_roles, :roles, :users, :custom_fields

    def setup
      set_language_if_valid 'en'
      User.current = nil
      @admin = users :users_001 # admin
      @jsmith = users :users_002 # not admin
      @rhill = users :users_004 # not admin
      @manager = roles :roles_001
      @manager.add_permission! :import_projects
      @plugin_fixture_path = Rails.root.join('plugins/redmine_project_types/test/fixtures/files')
      @fixture_name1 = 'import_project.csv'
      @fixture_name2 = 'import_project_with_unknown_custom_field.csv'
      @fixture_name3 = 'import_project_with_unknown_project_type.csv'
      @fixture_dir = Rails.root.join('test/fixtures/files')
      FileUtils.cp "#{@plugin_fixture_path}/#{@fixture_name1}", @fixture_dir
      FileUtils.cp "#{@plugin_fixture_path}/#{@fixture_name2}", @fixture_dir
      FileUtils.cp "#{@plugin_fixture_path}/#{@fixture_name3}", @fixture_dir
      find_project_type(id: 2) # onlinestore
      find_project_type(id: 5) # private-child
      find_project_type(id: 6) # project6
    end

    def teardown
      FileUtils.rm "#{@fixture_dir}/#{@fixture_name1}"
      FileUtils.rm "#{@fixture_dir}/#{@fixture_name2}"
      FileUtils.rm "#{@fixture_dir}/#{@fixture_name3}"
    end

    def test_authorized
      assert  ProjectImport.authorized?(@admin)
      assert  ProjectImport.authorized?(@jsmith)
      assert !ProjectImport.authorized?(@rhill)
    end

    def test_maps_name
      User.current = @admin
      import = generate_import_with_mapping @admin
      first, second, third = new_records(Project, 3) { import.run }
      assert_equal 'Order Transaction', first.name
      assert_equal 'Reporting', second.name
      assert_equal 'Marketing', third.name
    end

    def test_maps_description
      User.current = @jsmith
      import = generate_import_with_mapping @jsmith
      first, second, third = new_records(Project, 3) { import.run }
      assert_equal 'Processing an order', first.description
      assert_equal 'Rendering of accounts', second.description
      assert_equal 'Corner the market', third.description
    end

    def test_maps_identifier
      User.current = @jsmith
      import = generate_import_with_mapping @jsmith
      first, second, third = new_records(Project, 3) { import.run }
      assert_equal 'p100', first.identifier
      assert_equal 'p101', second.identifier
      assert_equal 'p102', third.identifier
    end

    def test_maps_is_public
      User.current = @jsmith
      import = generate_import_with_mapping @jsmith
      first, second, third = new_records(Project, 3) { import.run }
      assert_equal false, first.is_public
      assert_equal false, second.is_public
      assert_equal true, third.is_public
    end

    def test_maps_parent
      ecookbook = projects :projects_001
      User.current = @jsmith
      import = generate_import_with_mapping @jsmith
      first, second, third = new_records(Project, 3) { import.run }
      assert_equal ecookbook, first.parent
      assert_not second.parent
      assert_equal ecookbook, third.parent
    end

    def test_maps_inherit_members
      User.current = @jsmith
      import = generate_import_with_mapping @jsmith
      first, second, third = new_records(Project, 3) { import.run }
      assert first.inherit_members?
      assert second.inherit_members?
      assert_not third.inherit_members?
    end

    def test_maps_project_type
      User.current = @jsmith
      import = generate_import_with_mapping @jsmith
      first, second, third = new_records(Project, 3) { import.run }
      assert_equal ProjectType.find(2), first.project_type
      assert_equal ProjectType.find(5), second.project_type
      assert_equal ProjectType.find(6), third.project_type
    end

    def test_maps_custom_fields
      list_cf = custom_fields :custom_fields_003

      import = generate_import_with_mapping @jsmith
      import.mapping["cf_#{list_cf.id}"] = '7'
      import.save!

      first, second, third = new_records(Project, 3) { import.run }

      assert_equal 'Stable', first.custom_field_value(list_cf)
      assert_equal 'Beta', second.custom_field_value(list_cf)
      assert_equal 'Alpha', third.custom_field_value(list_cf)
    end

    def test_throw_error_if_not_all_custom_fields_are_mapped
      list_cf = custom_fields :custom_fields_003

      import = generate_import_with_mapping @jsmith, @fixture_name2
      import.mapping["cf_#{list_cf.id}"] = '7'
      import.mapping['cf_10000'] = '8'
      import.save!
      import.run
      import.unsaved_items.each do |item|
        assert_equal l(:error_could_not_map_all_custom_fields), item.message
      end
    end

    def test_throw_error_if_project_types_are_unknown
      list_cf = custom_fields :custom_fields_003

      import = generate_import_with_mapping @jsmith, @fixture_name3
      import.mapping["cf_#{list_cf.id}"] = '7'
      import.save!
      import.run
      import.unsaved_items.each do |item|
        assert_equal l(:error_no_project_type_given), item.message
      end
    end

    protected

    def generate_import(user, fixture_name = @fixture_name)
      import = ProjectImport.new
      import.file = uploaded_test_file(fixture_name, 'text/csv')
      import.user_id = user.id
      import.save!
      import
    end

    def generate_import_with_mapping(user, fixture_name = @fixture_name1)
      import = generate_import(user, fixture_name)

      import.settings = {
        'separator' => ';', 'wrapper' => '"', 'encoding' => 'UTF-8',
        'mapping' => {
          'name' => '0',
          'description' => '1',
          'identifier' => '2',
          'is_public' => '3',
          'parent' => '4',
          'inherit_members' => '5',
          'project_type' => '6'
        }
      }
      import.save!
      import
    end
  end
end
