# Redmine plugin for xmera called Project Types Plugin..
#
# Copyright (C) 2021 Liane Hampe <liaham@xmera.de>, xmera.
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
  module Integrations
    module ProjectsController
      module_function
      ##
      # Builds a projects_project_type object when creating a new
      # project
      # @params project [Project] A controller instance variable @project
      #
      def new(project)
        project.build_projects_project_type
      end

      ##
      # Creates nested attributes (projects_project_types_attributes)
      # with project_params by using strong parameters
      # and assigns projects project type default values
      #
      # @params params [Object] As used in a controller instance.
      #
      def create(params, project)
        update(params, project)
      end

      ##
      # Builds a projects_project_type object if not already done
      #
      def settings(project)
        return unless project.projects_project_type.nil?

        project.build_projects_project_type(id: project.id)
      end

      ## 
      # Updates nested attributes (projects_project_types_attributes)
      # with project_params by using strong parameters
      # and assigns projects project type default values
      #
      # @params params [Object] As used in a controller instance.
      #
      def update(params, project)
        return unless params[:project][:projects_project_type_attributes]

        project.update(project_params(params)) 
        project.project_types_default_values
      end
      
      ##
      # Uses strong parameters for nested attributes and others
      # ommit :inherit_members and enabled_module_names: [] since
      # there are special rules defined in project.rb which would
      # be ignored
      #
      # @params params [Object] As used in a controller instance.
      #
      def project_params(params)
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

      ##
      # Collects the projects custom field ids and turns them into the 
      # required data structure to store their values in the database.
      #
      # @note: This method is needed to include 'project_custom_field_ids' 
      #        in params.require(:project).permit(...)
      #
      def projects_custom_field_ids
        CustomField.where(type: "ProjectCustomField").ids.collect {|m| CustomField.find_by(id: m).multiple ? [m.to_s => [] ] : [m.to_s, :value]}
      end
    end
  end
end