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
    # The :projects_trackers table will be synchronized with the 
    # :project_types_trackers table.
    #
    # This is necessary in order to use the design of the core application,
    # especially where table queries refer to the original table :projects_trackers.
    #
    module Trackers
      ##
      # Synchronises from ProjectType model perspective
      #
      def synchronise_projects_trackers
        return if projects.empty?

        update_projects_trackers
      end

      ##
      # Synchronises from Tracker model perspective
      #
      def synchronise_projects_tracker(tracker)
        return if projects.empty?

        update_projects_tracker(tracker)
      end

      private

      def update_projects_trackers
        projects.each do |project|
          project.trackers&.delete_all
          project.tracker_ids = tracker_ids
        end
      end

      def update_projects_tracker(tracker)
        tracker.projects&.delete_all
        tracker.project_types.each do |project_type|
          tracker.projects << project_type.projects
        end
      end
    end
  end
end