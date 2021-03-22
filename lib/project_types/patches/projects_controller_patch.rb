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
      end

      module InstanceMethods
        ##
        # Replicate the project master if and only if the master is given.
        #
        # @override This method is overwritten from ProjectsController#create.
        #   It is almost identical to ProjectsController#copy unless it is 
        #   separated into single methods.
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

        private

        def project_type_id
          params[:project][:project_type_id].to_i
        end

        def prepare_source_project
          @source_project = ProjectType.projects.find(project_type_id)
        end

        def prepare_target_project
          @project = Project.copy_from(@source_project)
          @project.safe_attributes = target_project_params
        end

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

        private
        def target_project_params
          params[:project].delete('enabled_module_names')
          params[:project]
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
