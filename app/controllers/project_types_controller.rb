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

  helper :custom_fields

  before_action :require_admin

  def index
    @project_types = ProjectType.sorted.to_a
  end

  def new
    @issue_custom_fields = IssueCustomField.sorted.to_a
    @project_custom_fields = ProjectCustomField.sorted.to_a
    @project_type = ProjectType.new
  end

  def create
    @issue_custom_fields = IssueCustomField.sorted.to_a
    @project_custom_fields = ProjectCustomField.sorted.to_a
    @project_type = ProjectType.new
    @project_type.safe_attributes = params[:project_type]
    if @project_type.save
      flash[:notice] = l(:notice_successful_create)
      redirect_to project_types_path
    else
      render :new
    end
  end

  def edit
    @issue_custom_fields = IssueCustomField.sorted.to_a
    @project_custom_fields = ProjectCustomField.sorted.to_a
    find_project_type(secure_id_from_params)
  end

  def update
    find_project_type(secure_id_from_params)
    saved = save_with_project_type_relation_change

    if saved
      respond_to do |format|
        format.html do
          flash[:notice] = l(:notice_successful_update)
          redirect_to project_types_path
        end
        format.js { head 200 }
      end
    else
      respond_to do |format|
        format.html do
          edit
          render action: 'edit'
        end
        format.js { head 422 }
      end
    end
  end

  def destroy
    find_project_type(secure_id_from_params)
    if @project_type.projects.empty?
      @project_type.destroy
    else
      flash[:error] = l(:error_can_not_delete_project_type, count: count)
    end
    redirect_to project_types_path
  end

  private

  def find_project_type(id)
    @project_type ||= ProjectType.find(id.to_i)
  end

  def secure_id_from_params
    params[:id].to_i
  end

  def count
    @project_type.projects.count
  end

  def save_with_project_type_relation_change
    @project_type.safe_attributes = params[:project_type]
    @project_type.save
    saved = true
  rescue StandardError => e
    logger.error e.message
    saved = false
  ensure 
    return saved && @project_type.save
  end
end
