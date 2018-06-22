# Redmine plugin for xmera:isms called Project Types Plugin
#
# Copyright (C) 2017-18 Liane Hampe <liane.hampe@xmera.de>
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

require File.expand_path('../../test_helper', __FILE__)

class ProjectsControllerTest < ActionController::TestCase

 fixtures :projects, :versions, :users, :email_addresses, :roles, :members,
          :member_roles, :issues, :journals, :journal_details,
          :trackers, :projects_trackers, :issue_statuses,
          :enabled_modules, :enumerations, :boards, :messages,
          :attachments, :custom_fields, :custom_values, :time_entries,
          :wikis, :wiki_pages, :wiki_contents, :wiki_content_versions

 #plugin_fixtures :project_types, :projects_project_types
 
 ProjectType::TestCase.create_fixtures(Redmine::Plugin.find(:project_types).directory + '/test/fixtures/', [:project_types, :projects_project_types])
 
  # Default setting with admin user
  def setup
    @response   = ActionController::TestResponse.new
    @request    = ActionController::TestRequest.new
    User.current = nil
    @request.session[:user_id] = 1 # admin
    @project = Project.find(1)
    @project_type = ProjectType.find(1)
  end
  
  test "should create project with project type" do
    # assert_difference 'Project.count' do
      # post :create, :params => {
                                  # :project => {
                                    # :name => "blog",
                                    # :description => "weblog",
                                    # :homepage => 'http://weblog',
                                    # :identifier => "blog",
                                    # :is_public => 1,
#    
                                  # # :projects_project_type_attributes => {
                                    # # :project_type_id => 1,
                                    # # :id => self.id
                                  # # }
                                  # }
                                # }
    # end
    # assert_redirected_to '/projects/blog/settings'
    # assert_equal 1, Project.last.projects_project_type.project_type_id
  end
end
