# frozen_string_literal: true
#
# frozen_string_literal: true
#
# Redmine plugin for xmera called Project Types Plugin.
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
  ##
  # Copied from Project class to be available for ProjectType class.
  # Focus on methods which create EnabledModule objects in order to
  # set the project_type_id and not project_id.
  #
  module EnabledModules
    # Return the enabled module with the given name
    # or nil if the module is not enabled for the project
    def enabled_module(name)
      name = name.to_s
      enabled_modules.detect {|m| m.name == name}
    end

    # Return true if the module with the given name is enabled
    def module_enabled?(name)
      enabled_module(name).present?
    end

    def enabled_module_names=(module_names)
      if module_names && module_names.is_a?(Array)
        module_names = module_names.collect(&:to_s).reject(&:blank?)
        self.enabled_modules = module_names.collect {|name| enabled_modules.detect {|mod| mod.name == name} || EnabledModule.new(name: name)}
      else
        enabled_modules.clear
      end
    end

    # Returns an array of the enabled modules names
    def enabled_module_names
      enabled_modules.collect(&:name)
    end

    # Enable a specific module
    #
    # Examples:
    #   project_type.enable_module!(:issue_tracking)
    #   project_type.enable_module!("issue_tracking")
    def enable_module!(name)
      enabled_modules << EnabledModule.new(:name => name.to_s) unless module_enabled?(name)
    end

    # Disable a module if it exists
    #
    # Examples:
    #   project_type.disable_module!(:issue_tracking)
    #   project_type.disable_module!("issue_tracking")
    #   project_type.disable_module!(project_type.enabled_modules.first)
    def disable_module!(target)
      target = enabled_modules.detect{|mod| target.to_s == mod.name} unless enabled_modules.include?(target)
      target.destroy unless target.blank?
    end

################################################################################
# Permission related project methods 

    ##
    # Permissions are based on enabled_modules. This needs now to be checked
    # by ProjectType class instead of Project class.
    #
    def allowed_permissions
      @allowed_permissions ||= begin
        module_names = enabled_modules.loaded? ? enabled_modules.map(&:name) : enabled_modules.pluck(:name)
        Redmine::AccessControl.modules_permissions(module_names).collect {|p| p.name}
      end
    end

    def allowed_actions
      @actions_allowed ||= allowed_permissions.inject([]) { |actions, permission| actions += Redmine::AccessControl.allowed_actions(permission) }.flatten
    end

    # Return true if this project allows to do the specified action.
    # action can be:
    # * a parameter-like Hash (eg. :controller => 'projects', :action => 'edit')
    # * a permission Symbol (eg. :edit_project)
    def allows_to?(action)
      if archived?
        # No action allowed on archived projects
        return false
      end
      unless active? || Redmine::AccessControl.read_action?(action)
        # No write action allowed on closed projects
        return false
      end
      # No action allowed on disabled modules
      if action.is_a? Hash
        allowed_actions.include? "#{action[:controller]}/#{action[:action]}"
      else
        allowed_permissions.include? action
      end
    end

  end
end