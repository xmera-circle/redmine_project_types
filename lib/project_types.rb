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

# Project Types Libraries

# Plugin hook listener
require 'project_types/hooks/view_custom_fields_form_hook_listener'
require 'project_types/hooks/view_layouts_base_html_head_hook_listener'
require 'project_types/hooks/view_projects_form_top_hook_listener'

# Plugin patches
require 'project_types/patches/custom_fields_controller_patch'
require 'project_types/patches/issue_custom_field_patch'
require 'project_types/patches/project_custom_field_patch'
require 'project_types/patches/project_patch'
require 'project_types/patches/project_query_patch'
require 'project_types/patches/projects_controller_patch'
require 'project_types/patches/tracker_patch'

# Association
require 'project_types/associations/modules'
require 'project_types/associations/trackers'

# Switch
require 'project_types/switch/modules'
require 'project_types/switch/trackers'
require 'project_types/switch/issue_custom_fields'
require 'project_types/switch/project_custom_fields'

# Synchronization
require 'project_types/synchronisation/modules'
require 'project_types/synchronisation/trackers'
require 'project_types/synchronisation/issue_custom_fields'

module ProjectTypes
  class << self
    def missing?
      return false if Rails.env.test?

      !any?
    end

    def any?
      false
      #return false unless table_found?

      # ProjectType.any?
    end

    private

    def table_found?(table_name = :project_types)
      ActiveRecord::Base.connection.table_exists?(table_name)
    end
  end
end
