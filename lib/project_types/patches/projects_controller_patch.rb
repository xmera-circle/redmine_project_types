# Redmine plugin for xmera called Project Types Plugin..
#
# Copyright (C) 2017-19 Liane Hampe <liane.hampe@xmera.de>.
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
        
      # Builds an projects_project_type object
      def new
        super
        @projects_project_type = @project.build_projects_project_type
      end
         
      # Builds a projects_project_type object if not already done
      def settings
        super
        if @project.projects_project_type.nil?
          @projects_project_type = @project.build_projects_project_type(:id => @project.id)
        end
      end
        
      # Updates nested attributes (projects_project_types_attributes)
      # with project_params by using strong parameters
      # and assigns projects project type default values
      def update
        @project.safe_attributes = params[:project]
        if @project.save
          if params[:project][:projects_project_type_attributes]
            @project.update(project_params) 
            @project.project_types_default_values
          end
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
        
      # Creates nested attributes (projects_project_types_attributes)
      # with project_params by using strong parameters
      # and assigns projects project type default values
      def create
        @issue_custom_fields = IssueCustomField.sorted.to_a
        @trackers = Tracker.sorted.to_a
        @project = Project.new
        @project.safe_attributes = params[:project]
      
        if @project.save
          if params[:project][:projects_project_type_attributes]
            @project.update(project_params) 
            @project.project_types_default_values
          end
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
      
      def modules
        @project.enabled_module_names = params[:enabled_module_names] unless params[:enabled_module_names].nil?
        flash[:notice] = l(:notice_successful_update)
        redirect_to settings_project_path(@project, :tab => 'modules')
      end
    
      private
        
      # Collects the projects custom field ids and turns them into the 
      # required data structure to store their values in the database.
      # method is needed to include 'project_custom_field_ids' in params.require(:project).permit(...)
      def projects_custom_field_ids
         CustomField.where(type: "ProjectCustomField").ids.collect {|m| CustomField.find_by(id: m).multiple ? [m.to_s => [] ] : [m.to_s, :value]}
      end
        
      # Uses strong parameters for nested attributes and others
      # ommit :inherit_members and enabled_module_names: [] since
      # there are special rules defined in project.rb which would
      # be ignored
      def project_params
        params.require(:project).permit(:name, 
                                        :description,
                                        :homepage,
                                        :is_public,
                                        :parent_id,
                                        :identifier,
                                     #   :inherit_members,
                                        :default_version_id,
                                     #   enabled_module_names:[],
                                        :custom_field_values => [projects_custom_field_ids],
                                        issue_custom_field_ids:[],
                                        tracker_ids:[],
                                        projects_project_type_attributes: [:id, :project_type_id])
      end   
    end
  end
end

# Apply patch
Rails.configuration.to_prepare do
  unless ProjectsController.included_modules.include?(ProjectTypes::Patches::ProjectsControllerPatch)
    ProjectsController.prepend(ProjectTypes::Patches::ProjectsControllerPatch)
  end
end
