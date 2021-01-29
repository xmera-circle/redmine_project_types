class ProjectTypesController < ApplicationController
  layout 'admin'
  self.main_menu = false

  before_action :require_admin, :except => :index
  before_action :require_admin_or_api_request, :only => :index
  # accept_api_auth :index

  def index
    @project_types = ProjectType.sorted.to_a
  end

  def new
    @project_type = ProjectType.new
  end

  def create
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
    find_project_type(params[:id])
  end

  def update
    find_project_type(params[:id])
    @project_type.safe_attributes = params[:project_type]
    if @project_type.save
      respond_to do |format|
        format.html {
          flash[:notice] = l(:notice_successful_update)
          redirect_to project_types_path
        }
        format.js { head 200 }
      end
    else
      respond_to do |format|
        format.html {
          edit
          render action: 'edit'
        }
        format.js { head 422 }
      end
    end
  end
  def destroy
    find_project_type(params[:id])
    unless @project_type.projects.empty?
      flash[:error] = l(:error_can_not_delete_project_type)
    else
      @project_type.destroy
    end
    redirect_to project_types_path
  end

  private

  def find_project_type(id)
    @project_type ||= ProjectType.find(id.to_i)
  end
end