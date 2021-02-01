class ProjectTypesController < ApplicationController
  layout 'admin'
  self.main_menu = false

  before_action :require_admin

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
    find_project_type(secure_id_from_params)
  end

  def update
    find_project_type(secure_id_from_params)
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
    find_project_type(secure_id_from_params)
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

  def secure_id_from_params
    params[:id].to_i
  end
end