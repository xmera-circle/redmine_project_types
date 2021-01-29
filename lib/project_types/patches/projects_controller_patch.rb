# Redmine plugin for xmera called Project Types Plugin..
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

module ProjectTypes
  module Patches
    module ProjectsControllerPatch
      def new
        super
       # @projects_project_type = ProjectTypes::Integrations::ProjectsController.new(@project)
      end


      def create
        @issue_custom_fields = IssueCustomField.sorted.to_a
        @trackers = Tracker.sorted.to_a
        @project = Project.new
        @project.safe_attributes = params[:project]
      
        if @project.save
       #   ProjectTypes::Integrations::ProjectsController.create(params, @project)
          unless User.current.admin?
            @project.add_default_member(User.current)
          end
          respond_to do |format|
            format.html {
              flash[:notice] = l(:notice_successful_create)
              if params[:continue]
                attrs = {:parent_id => @project.parent_id}.reject {|k,v| v.nil?}
                redirect_to new_project_path(attrs)
              else
                redirect_to settings_project_path(@project)
              end
            }
            format.api  { render :action => 'show', :status => :created, :location => url_for(:controller => 'projects', :action => 'show', :id => @project.id) }
          end
        else
          respond_to do |format|
            format.html { render :action => 'new' }
            format.api  { render_validation_errors(@project) }
          end
        end
      end
         
      def settings
        super
       # @project_type = ProjectTypes::Integrations::ProjectsController.settings(@project)
      end

      def update
        @project.safe_attributes = params[:project]
        if @project.save
      #    ProjectTypes::Integrations::ProjectsController.update(params, @project)
          respond_to do |format|
          format.html {
            flash[:notice] = l(:notice_successful_update)
            redirect_to settings_project_path(@project)
          }
          format.api  { render_api_ok }
          end
        else
          respond_to do |format|
              format.html {
                settings
                render :action => 'settings'
              }
              format.api  { render_validation_errors(@project) }
          end
        end
      end
    end
  end
end

# Apply patch
ActiveSupport::Reloader.to_prepare do
  unless ProjectsController.included_modules.include?(ProjectTypes::Patches::ProjectsControllerPatch)
    ProjectsController.prepend(ProjectTypes::Patches::ProjectsControllerPatch)
  end
end
