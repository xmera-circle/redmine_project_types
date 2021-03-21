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

class ProjectTypesController < ApplicationController
  layout 'admin'
  self.main_menu = false

  helper :admin

  before_action :require_admin
  before_action :find_project, except: %i[index destroy]
  before_action :find_project_type, only: %i[destroy]
  require_sudo_mode :destroy

  def index
    @status = params[:status] || 1

    scope = ProjectType.projects.status(@status).sorted
    scope = scope.like(params[:name]) if params[:name].present?

    @project_count = scope.count
    @project_pages = Paginator.new @project_count, per_page_option, params['page']
    @projects = scope.limit(@project_pages.per_page).offset(@project_pages.offset).to_a

    render :action => "index", :layout => false if request.xhr?
  end

  def archive
    unless @project.archive
      flash[:error] = l(:error_can_not_archive_project)
    end
    redirect_to_referer_or project_types_path(:status => params[:status])
  end

  def unarchive
    unless @project.active?
      @project.unarchive
    end
    redirect_to_referer_or project_types_path(:status => params[:status])
  end

    def destroy 
    @project_to_destroy = @project_type
    if api_request? || params[:confirm]
      @project_to_destroy.destroy
      respond_to do |format|
        format.html { redirect_to project_types_path }
        format.api  { render_api_ok }
      end
    end
    # hide project in layout
    @project = nil
  end

  private 

  # Find project of id params[:id]
  def find_project_type(identifier=params[:id])
    @project_type = ProjectType.projects.find_by(identifier: identifier)
  rescue ActiveRecord::RecordNotFound
    render_404
  end

end
