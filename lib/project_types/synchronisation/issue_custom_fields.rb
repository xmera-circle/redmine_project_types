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
    # The :custom_fields_projects table will be synchronized with the 
    # :custom_fields_project_types table.
    #
    # This is necessary in order to use the design of the core application,
    # especially where table queries refer to the original table
    # :custom_fields_projects.
    #
    module IssueCustomFields
      ##
      # Synchronises from ProjectType model perspective
      #
      def synchronise_issue_custom_fields_projects
        return if projects.empty?

        update_issue_custom_fields_projects
      end

      ##
      # Synchronises from IssueCustomField model perspective
      #
      def synchronise_issue_custom_field_projects(custom_field)
        return if projects.empty?

        update_issue_custom_field_projects(custom_field)
      end

      private

      def update_issue_custom_fields_projects
        projects.each do |project|
          project.issue_custom_fields&.delete_all
          project.issue_custom_field_ids = issue_custom_field_ids
        end
      end

      def update_issue_custom_field_projects(custom_field)
        custom_field.projects&.delete_all
        custom_field.project_types.each do |project_type|
          custom_field.projects << project_type.projects
        end
      end
    end
  end
end