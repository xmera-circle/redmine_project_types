# frozen_string_literal: true

#
# Redmine plugin for xmera called Project Types Plugin.
#
#  Copyright (C) 2022 Liane Hampe <liane.hampe@xmera.de>
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

module ProjectTypes
  class ProjectImportTest < IntegrationTest
    fixtures :users, :roles, :projects, :members, :member_roles

    def setup
      @jsmith = users :users_002
      @dlopper = users :users_003
      @manager = roles :roles_001
      @manager.add_permission! :import_projects
    end

    test 'should show project import menu item if admin' do
      log_user('admin', 'admin')
      get projects_path
      assert :success
      assert_select '.icon-actions'
      assert_select '.icon-import'
    end

    test 'should show project import menu item if user allowed to' do
      log_user('jsmith', 'jsmith')
      get projects_path
      assert :success
      assert_select '.icon-actions'
      assert_select '.icon-import'
    end

    test 'should not show project import menu item if user not allowed to' do
      log_user('dlopper', 'foo')
      get projects_path
      assert :success
      assert_select '.icon-actions', 0
      assert_select '.icon-import', 0
    end
  end
end
