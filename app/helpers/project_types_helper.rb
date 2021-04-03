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

##
# Provides some helper methods usefull for Project instances which are
# marked as :is_project_type.
#
module ProjectTypesHelper
  ##
  # Similar to ApplicationHelper#toogle_checkboxes_link but uses a text instead
  # of the check icon.
  #
  def toggle_checkboxes_text_link(text, selector)
    link_to_function text,
                     "toggleCheckboxesBySelector('#{selector}')",
                     title: "#{l(:button_check_all)} / #{l(:button_uncheck_all)}"
  end

  def number_of_assigned_projects(project)
    return unless project.project_type_master?

    l(:text_number_of_assigned_projects_to_project_type, count: assigned_projects(project)&.count || 0).to_s
  end

  def assigned_projects(project)
    project.respond_to?(:relatives) ? project.relatives : find_project_type(project).relatives
  end

  def find_project_type(project)
    ProjectType.find_by(id: project.id)
  end
end
