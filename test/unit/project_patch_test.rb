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
  class ProjectPatchTest < ActiveSupport::TestCase
    include Redmine::I18n
    extend ProjectTypes::LoadFixtures

    fixtures :projects,
             :members,
             :member_roles,
             :roles,
             :users

    test 'should belong_to project_type' do
      assert association = Project.reflect_on_association(:project_type)
      assert_equal :project_type, association&.name
      assert_equal project_type_options, association&.options
    end

    test 'should respond to project_type_master?' do
      assert project(id: 1).respond_to? :project_type_master?
    end

    test 'should respond to relatives' do
      assert project(id: 1).respond_to? :relatives
    end

    test 'should have no relatives' do
      assert project(id: 1).relatives.none?
    end

    test 'should have safe project_type_id attribute' do
      assert project(id: 1).safe_attribute? 'project_type_id'
    end

    test 'should have safe is_project_type attribute' do
      assert project(id: 1).safe_attribute? 'is_project_type'
    end

    test 'should return NullProjectType when project has no project type' do
      assert project(id: 1).project_type.is_a? NullProjectType
    end

    test 'should use NullProjectType attributes when project has no project type' do
      name = NullProjectType.new.name
      project_custom_fields = NullProjectType.new.project_custom_fields

      assert_equal name, project(id: 1).project_type.name
      assert_equal project_custom_fields, project(id: 1).project_type.project_custom_fields
      assert_equal name, NullProjectType.new.to_s
    end

    test 'should add prefix to project type master identifier' do
      project_type_master = Project.create(name: 'Project Type Master',
                                           identifier: 'project-type-master',
                                           is_project_type: true)
      assert_equal 'ocm-project-type-master', project_type_master.identifier
    end

    private

    def project_type_options
      Hash({ foreign_key: :project_type_id,
             optional: true,
             inverse_of: :relatives })
    end

    def project(id:)
      Project.find(id.to_i)
    end
  end
end
