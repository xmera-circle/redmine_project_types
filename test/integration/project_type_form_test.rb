# frozen_string_literal: true

#
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

module ProjectTypes
  class ProjectTypeFormTest < Redmine::IntegrationTest
    extend ProjectTypes::LoadFixtures
    include ProjectTypes::AuthenticateUser
    include ProjectTypes::CreateProjectType
    include Redmine::I18n

    fixtures :users, :project_types

    test 'project type form fields' do
      log_user('admin', 'admin')
      get new_project_type_path
      assert_response :success
      assert_select '#project_type_name'
      assert_select '#project_type_description'
      assert_select '#project_type_is_master_parent'
    end
   
  end
end
