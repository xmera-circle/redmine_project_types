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
  # The :enabled_modules table will be synchronized with the :project_type_modules
  # table.
  #
  # This is necessary since there are some methods in the core that 
  # refer directly to EnabledModule class:
  #
  #  - lib/redmine.rb: Redmine::MenuManager.map :application_menu do |menu| etc.
  #  - app/model/project.rb: 
  #     - Project#rolled_up_trackers_base_scope
  #     - Project.allowed_to_condition
  #
  # These methods would not reached via delegation as done for other related 
  # methods as defined in ProjectTypes::ProjectTypeModules.
  #
  module EnabledModuleSync
    def synchronize_modules
      project_type_module_names, project_ids = find_involved_objects
      return if project_ids.nil?

      delete_project_module(project_ids)
      create_project_modules(project_type_module_names, project_ids)
    end

    private

    def find_involved_objects
      names = enabled_module_names
      ids = projects.map(&:id)
      [names, ids]
    end

    def delete_project_module(project_ids)
      project_ids.each do |id|
        project_module = EnabledModule.where(project_id: id)
        project_module.delete_all if project_module.any?
      end
    end

    def create_project_modules(project_type_module_names, project_ids)
      attrs = []
      project_type_module_names.each do |name|
        project_ids.each do |id|
          attrs << { project_id: id, name: name }
        end
      end
      EnabledModule.create(attrs)
    end
  end
end