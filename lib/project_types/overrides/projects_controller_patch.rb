# frozen_string_literal: true

#
# Redmine plugin for xmera called Project Types Plugin.
#
# Copyright (C) 2017 - 2022 Liane Hampe <liaham@xmera.de>, xmera.
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
  module Overrides
    # Patches projects_controller.rb from Redmine Core
    module ProjectsControllerPatch
      def self.prepended(base)
        base.prepend(InstanceMethods)
      end

      module InstanceMethods
        ##
        # Add ProjectCustomField data for providing custom settings.
        #
        # @override ProjectsController#new
        #
        def new
          super
          @project_custom_fields = ProjectCustomField.fields_for_select
          @project_custom_field_ids = @project.project_custom_field_ids
        end

        ##
        # create_project_from_project_type_master if and only if a type was selected.
        #
        # @override ProjectsController#create.
        #
        #
        def create
          return super unless project_type_id.positive?

          prepare_source_project
          prepare_target_project

          if @source_project
            create_project_from_project_type_master(@source_project, @project)
          else
            flash[:warning] = l(:warning_project_type_is_missing)
            redirect_to settings_project_path(@project)
          end
        rescue ActiveRecord::RecordNotFound
          # @source_project not found
          render_404
        end

        ##
        #
        # @override ProjectsController#update
        #
        def update
          assign_attributes_from_params

          if project_valid?
            respond_to do |format|
              format.html do
                flash[:notice] = l(:notice_successful_update)
                redirect_to settings_project_path(@project, params[:tab])
              end
              format.api  { render_api_ok }
            end
          else
            respond_to do |format|
              format.html do
                settings
                render action: 'settings'
              end
              format.api { render_validation_errors(@project) }
            end
          end
        end

        ##
        # @override ProjectsController#settings
        #
        def settings
          @project_type_masters = ProjectType.masters_for_select
          @project_custom_fields = ProjectCustomField.fields_for_select
          @project_custom_field_ids = @project.project_custom_field_ids
          super
        end
      end
    end
  end
end

# Apply patch
Rails.configuration.to_prepare do
  unless ProjectsController.included_modules.include?(ProjectTypes::Overrides::ProjectsControllerPatch)
    ProjectsController.prepend ProjectTypes::Overrides::ProjectsControllerPatch
  end
end
