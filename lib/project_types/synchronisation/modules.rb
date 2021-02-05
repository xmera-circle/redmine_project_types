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
  module Synchronisation
    ##
    # The :enabled_modules table will be synchronized with the 
    # :enabled_project_type_modules table.
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
    # methods which are defined in ProjectTypes::Association::Modules.
    #
    module Modules
      def synchronise_modules
        return if project_ids.empty?

        delete_project_module(project_ids)
        create_project_modules(enabled_module_names, project_ids)
      end

      private

      def delete_project_module(project_ids)
        project_ids.each do |id|
          project_modules = EnabledModule.where(project_id: id)
          project_modules&.delete_all
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
end