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
  class ProjectPatchTest < ActiveSupport::TestCase
    include Redmine::I18n
    extend ProjectTypes::LoadFixtures

    fixtures :projects,
             :members,
             :member_roles,
             :roles,
             :users,
             :project_types

    test 'should belong_to project_type' do
      assert association = Project.reflect_on_association(:project_type)
      assert_equal :project_type, association&.name
      assert_equal project_type_options, association&.options
    end

    test 'should respond to project_type?' do
      assert project(id: 1).respond_to? :project_type?
    end

    test 'should have safe project_type_id attribute' do
      assert project(id: 1).safe_attribute? 'project_type_id'
    end

    test 'should have safe is_master attribute' do
      assert project(id: 1).safe_attribute? 'is_master'
    end

    private

    def project_type_options
      Hash({ inverse_of: :relatives,
             foreign_key: :project_type_id })
    end

    def project(id:, type_id: nil)
      project = Project.find(id.to_i)
      project.project_type_id = type_id
      project.save
      project
    end
  end
end
