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
        self.enabled_modules = module_names.collect {|name| enabled_modules.detect {|mod| mod.name == name} || EnabledProjectTypeModule.new(name: name)}
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
      enabled_modules << EnabledProjectTypeModule.new(:name => name.to_s) unless module_enabled?(name)
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
  end
end