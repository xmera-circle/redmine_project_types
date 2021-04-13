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

module ProjectTypes
  module Patches
    # Patches projects_controller.rb from Redmine Core
    module ProjectsControllerPatch
      def self.prepended(base)
        base.prepend(InstanceMethods)
        base.after_action :sanitize_project_custom_field_values, only: %i[copy]
      end

      module InstanceMethods
        ##
        # Replicate the project type if and only if a type was selected.
        #
        # @override ProjectsController#create.
        #
        #
        def create
          return super unless project_type_id.positive?

          prepare_source_project
          prepare_target_project

          if @source_project
            replicate(@source_project, @project)
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
          project_assign_attributes

          if project_valid?
            respond_to do |format|
              format.html {
                flash[:notice] = l(:notice_successful_update)
                redirect_to settings_project_path(@project, params[:tab])
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

        private

        def project_assign_attributes
          @project.safe_attributes = params[:project]
        rescue ActiveRecord::RecordNotSaved => e
          @project.errors.add :base, e unless @project.errors.any?
        end

        def project_valid?
          @project.errors.none? && @project.save
        end

        def project_type_id
          params[:project][:project_type_id].to_i
        end

        def prepare_source_project
          @source_project = ProjectType.masters.find(project_type_id)
        end

        def prepare_target_project
          @project = Project.copy_from(@source_project)
          @project.safe_attributes = target_project_params
        end

        ##
        # Similar to ProjectsController#copy.
        #
        def replicate(source, target)
          if target.copy(source)
            flash[:notice] = l(:notice_successful_create)
            redirect_to settings_project_path(target)
          elsif !target.new_record?
            # Project was created
            # But some objects were not copied due to validation failures
            # (eg. issues from disabled trackers)
            # TODO: inform about that
            redirect_to settings_project_path(target)
          end
        end

        def target_project_params
          params[:project].delete('enabled_module_names')
          params[:project].delete('custom_field_values')
          params[:project]
        end

        ##
        # Find and delete copied custom values of the newly created project
        # belonging to project custom fields which were not selected.
        #
        def sanitize_project_custom_field_values
          return if @project.nil? || @project.new_record?

          values_to_delete = find_values_to_delete
          CustomValue.delete(values_to_delete.map(&:id)) if values_to_delete.any?
        end

        def find_values_to_delete
          all_custom_values.select { |value| value_to_delete?(value.custom_field_id) }
        end

        def all_custom_values
          CustomValue
            .where({ customized: @project.id, customized_type: 'Project' })
            .includes(:customized)
        end

        def value_to_delete?(candidate_id)
          !valid_ids.include?(candidate_id)
        end

        def valid_ids
          @project.project_custom_field_ids
        end
      end
    end
  end
end

# Apply patch
Rails.configuration.to_prepare do
  unless ProjectsController.included_modules.include?(ProjectTypes::Patches::ProjectsControllerPatch)
    ProjectsController.prepend ProjectTypes::Patches::ProjectsControllerPatch
  end
end
