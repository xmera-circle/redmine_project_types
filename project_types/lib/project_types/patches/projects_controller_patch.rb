require_dependency 'projects_controller'

module ProjectTypes
  module Patches
    module ProjectsControllerPatch
      def self.included(base) # :nodoc:
        base.send(:include, InstanceMethods)
        
        base.class_eval do
          unloadable # Send unloadable so it will not be unloaded in development
    
          # Core Extensions
          alias_method_chain :new, :project_type_selection
          alias_method_chain :settings, :project_type_selection
          alias_method_chain :update, :project_type_selection
          alias_method_chain :create, :project_type_selection
        end
      end
      
      module InstanceMethods
        
        # Builds an projects_project_type object
        def new_with_project_type_selection
          new_without_project_type_selection
          @projects_project_type = @project.build_projects_project_type
        end
         
        # Builds a projects_project_type object if not already done
        def settings_with_project_type_selection
          settings_without_project_type_selection
          if @project.projects_project_type.nil?
            @projects_project_type = @project.build_projects_project_type(:id => @project.id)
          end
        end
        
        # Updates nested attributes (projects_project_types_attributes)
        # with nested_params by using strong parameters
        # and assigns projects project type default values
        def update_with_project_type_selection
          @project.safe_attributes = params[:project]
          if @project.save
            @project.update(nested_params)
            @project.project_types_default_values
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
        # with nested_params by using strong parameters
        # and assigns projects project type default values
        def create_with_project_type_selection
          @issue_custom_fields = IssueCustomField.sorted.to_a
          @trackers = Tracker.sorted.to_a
          @project = Project.new
          @project.safe_attributes = params[:project]
      
          if @project.save
            @project.update(nested_params)
            @project.project_types_default_values
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
    
        private
        
        # Collects the projects custom field ids and turns them into the 
        # required data structure to store their values in the database.
        # method is needed to include 'project_custom_field_ids' in params.require(:project).permit(...)
        def projects_custom_field_ids
           CustomField.where(type: "ProjectCustomField").ids.collect {|m| CustomField.find_by(id: m).multiple ? [m.to_s => [] ] : [m.to_s, :value]}
        end
        
        # Uses strong parameters for nested attributes and others
        def nested_params
          params.require(:project).permit(:name, 
                                          :description,
                                          :homepage,
                                          :is_public,
                                          :parent_id,
                                          :identifier,
                                          :inherit_members,
                                          :default_version_id,
                                          enabled_module_names:[],
                                          :custom_field_values => [projects_custom_field_ids],
                                          issue_custom_field_ids:[],
                                          tracker_ids:[],
                                          projects_project_type_attributes: [:id, :project_type_id])
        end   
      end 
    end
  end
end

# Apply patch
Rails.configuration.to_prepare do
  unless ProjectsController.included_modules.include?(ProjectTypes::Patches::ProjectsControllerPatch)
    ProjectsController.send(:include, ProjectTypes::Patches::ProjectsControllerPatch)
  end
end
