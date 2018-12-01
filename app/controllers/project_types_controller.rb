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

class ProjectTypesController < ApplicationController
  unloadable
  
  include ActiveModel::Dirty
  include ProjectTypesHelper
  
  # Enables the sidebar with admin menu
  layout 'admin'
  self.main_menu = false # enable for redmine 3.4
 
  before_filter :require_admin, :except => :index
  before_filter :require_admin_or_api_request, :only => :index
  accept_api_auth :index

 
  def index
    @project_types = ProjectType.sorted.to_a
    respond_to do |format|
      format.html { render :layout => false if request.xhr? }
      format.api
    end
  end
  
  def new
    @project_type ||=  ProjectType.new
    @project_types = ProjectType.sorted.to_a
  end
  
  def create
    @project_type = ProjectType.new(project_type_params)
    if @project_type.save
      
      @project_types_default_modules = ProjectTypesDefaultModule.where(project_type_id: @project_type.id)
      @project_types_default_trackers = ProjectTypesDefaultTracker.where(project_type_id: @project_type.id)
      
      create_multi_default_modules(@project_types_default_modules, project_types_default_module_params)
      create_multi_default_trackers(@project_types_default_trackers, project_types_default_tracker_params)
      
      flash[:notice] = l(:notice_successful_create)
      redirect_to project_types_path
      return
    end
    new
    render :action => 'new'
  end
  
  def edit
    @project_type ||= ProjectType.find(params[:id])
    @project_types_default_modules = ProjectTypesDefaultModule.where(project_type_id: @project_type.id)
    @project_types_default_trackers = ProjectTypesDefaultTracker.where(project_type_id: @project_type.id)
  end

  def update
     @project_type = ProjectType.find(params[:id])
     @project_types_default_modules = ProjectTypesDefaultModule.where(project_type_id: @project_type.id)
     @project_types_default_trackers = ProjectTypesDefaultTracker.where(project_type_id: @project_type.id)

     if @project_type.update_attributes(project_type_params)    

       if @project_type.previous_changes[:position].nil?
         create_multi_default_modules(@project_types_default_modules, project_types_default_module_params)
         create_multi_default_trackers(@project_types_default_trackers, project_types_default_tracker_params)
       end

      respond_to do |format|
        format.html {
          flash[:notice] = l(:notice_successful_update)
          redirect_to project_types_path(:page => params[:page])
        }
        format.js { render :nothing => true }
      end
    else
      respond_to do |format|
        format.html { 
          edit 
          render :action => 'edit' 
          }
        format.js { render :nothing => true, :status => 422 }
      end
    end
  end
  
  def destroy
    @project_type = ProjectType.find(params[:id])
    unless @project_type.projects.empty?
      flash[:error] = l(:error_unable_delete_project_type)
    else
      @project_type.destroy
      # The corresponding project_types_default_modules will be deleted automatically
    end
    redirect_to project_types_path

  rescue
    flash[:error] = l(:error_unable_delete_project_type)
    redirect_to project_types_path
  end
  
private

  def project_type_params
    params.require(:project_type).permit(:name, :description, :identifier, :is_public, :default_user_role_id, :position )
  end
  
  def project_types_default_module_params
    params.require(:project_types_default_module).permit(:project_type_id, name:[]) 
  end
  
  def project_types_default_tracker_params
    params.require(:project_types_default_tracker).permit(:project_type_id, tracker_id:[])
  end

end
