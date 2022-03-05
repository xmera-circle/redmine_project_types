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
  class ProjectCustomFieldPatchTest < ActiveSupport::TestCase
    include Redmine::I18n
    extend ProjectTypes::LoadFixtures

    fixtures :projects,
             :members,
             :member_roles,
             :roles,
             :users,
             :custom_fields

    test 'should have and belong to many projects' do
      assert association = ProjectCustomField.reflect_on_association(:projects)
      assert_equal :projects, association&.name
      assert_equal project_custom_field_options, association&.options
    end

    test 'should have safe project_ids attribute' do
      assert project_custom_field.safe_attribute? 'project_ids'
    end

    private

    def project_custom_field_options
      Hash({ join_table: 'custom_fields_projects',
             foreign_key: 'custom_field_id',
             autosave: true })
    end

    def project_custom_field
      CustomField.find(3)
    end
  end
end
