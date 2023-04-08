# frozen_string_literal: true

#
# Redmine plugin for xmera called Project Types Plugin.
#
# Copyright (C) 2017-2023 Liane Hampe <liaham@xmera.de>, xmera Solutions GmbH.
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

# Extensions
require_relative 'project_types/extensions/issue_custom_field_patch'
require_relative 'project_types/extensions/project_custom_field_patch'
require_relative 'project_types/extensions/project_patch'
require_relative 'project_types/extensions/project_query_patch'
require_relative 'project_types/extensions/projects_controller_patch'

# Plugin hook listener
require_relative 'project_types/hooks/view_custom_fields_form_hook_listener'
require_relative 'project_types/hooks/view_layouts_base_html_head_hook_listener'
require_relative 'project_types/hooks/view_projects_form_top_hook_listener'

# Overrides
require_relative 'project_types/overrides/admin_controller_patch'
require_relative 'project_types/overrides/application_helper_patch'
require_relative 'project_types/overrides/principal_memberships_controller_patch'
require_relative 'project_types/overrides/project_custom_field_patch'
require_relative 'project_types/overrides/project_patch'
require_relative 'project_types/overrides/project_query_patch'
require_relative 'project_types/overrides/projects_controller_patch'

# Redmine field format
require_relative 'redmine/field_format//project_type_format'

##
# Initialize some plugin requirements and definitions.
#
module ProjectTypes
  class << self
    def setup
      define_permissions
      %w[issue_custom_field_patch project_custom_field_extension_patch
         project_extension_patch project_query_extension_patch
         projects_controller_extension_patch
         admin_controller_patch application_helper_patch
         principal_memberships_controller_patch project_custom_field_override_patch
         project_override_patch project_query_override_patch
         projects_controller_override_patch].each do |patch|
        AdvancedPluginHelper::Patch.register(send(patch))
      end
      AdvancedPluginHelper::Patch.apply do
        { klass: ProjectTypes,
          method: :add_helpers }
      end
    end

    private

    def define_permissions
      Redmine::AccessControl.map do |map|
        map.permission :manage_project_type_master, { projects: %i[new create edit update destroy] }, require: :loggedin
        map.permission :import_projects, {}
      end
    end

    def issue_custom_field_patch
      { klass: IssueCustomField,
        patch: ProjectTypes::Extensions::IssueCustomFieldPatch,
        strategy: :include }
    end

    def project_custom_field_extension_patch
      { klass: ProjectCustomField,
        patch: ProjectTypes::Extensions::ProjectCustomFieldPatch,
        strategy: :include }
    end

    def project_extension_patch
      { klass: Project,
        patch: ProjectTypes::Extensions::ProjectPatch,
        strategy: :include }
    end

    def project_query_extension_patch
      { klass: ProjectQuery,
        patch: ProjectTypes::Extensions::ProjectQueryPatch,
        strategy: :include }
    end

    def projects_controller_extension_patch
      { klass: ProjectsController,
        patch: ProjectTypes::Extensions::ProjectsControllerPatch,
        strategy: :include }
    end

    def admin_controller_patch
      { klass: AdminController,
        patch: ProjectTypes::Overrides::AdminControllerPatch,
        strategy: :prepend }
    end

    def application_helper_patch
      { klass: ApplicationHelper,
        patch: ProjectTypes::Overrides::ApplicationHelperPatch,
        strategy: :prepend }
    end

    def principal_memberships_controller_patch
      { klass: PrincipalMembershipsController,
        patch: ProjectTypes::Overrides::PrincipalMembershipsControllerPatch,
        strategy: :prepend }
    end

    def project_custom_field_override_patch
      { klass: ProjectCustomField,
        patch: ProjectTypes::Overrides::ProjectCustomFieldPatch,
        strategy: :prepend }
    end

    def project_override_patch
      { klass: Project,
        patch: ProjectTypes::Overrides::ProjectPatch,
        strategy: :prepend }
    end

    def project_query_override_patch
      { klass: ProjectQuery,
        patch: ProjectTypes::Overrides::ProjectQueryPatch,
        strategy: :prepend }
    end

    def projects_controller_override_patch
      { klass: ProjectsController,
        patch: ProjectTypes::Overrides::ProjectsControllerPatch,
        strategy: :prepend }
    end

    def add_helpers
      ProjectsController.helper(ProjectTypesHelper)
      CustomFieldsController.helper(ProjectTypesHelper)
      TrackersController.helper(ProjectTypesHelper)
    end
  end
end
