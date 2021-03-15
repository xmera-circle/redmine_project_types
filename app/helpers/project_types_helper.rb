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

module ProjectTypesHelper
  def link_to_master(project_type)
    master = project_type.master
    return '' unless master

    link_to master.name, project_path(master)
  end

  def modules_multiselect(_project_type_id, choices, _options = {})
    hidden_field_tag('project_type[enabled_module_names][]', '').html_safe +
      choices.collect do |choice|
        text, value = (choice.is_a?(Array) ? choice : [choice, choice])
        content_tag(
          'label',
          check_box_tag(
            'project_type[enabled_module_names][]',
            value,
            @project_type.module_enabled?(value),
            id: nil
          ) + text.to_s,
          class: 'floating'
        )
      end.join.html_safe
  end

  def available_project_modules
    Redmine::AccessControl.available_project_modules.collect do |m|
      [l_or_humanize(m, prefix: 'project_module_'), m.to_s]
    end
  end

  def trackers_multiselect(_project_type_id, choices, _options = {})
    hidden_field_tag('project_type[tracker_ids][]', '').html_safe +
      choices.collect do |choice|
        text, value = (choice.is_a?(Array) ? choice : [choice, choice])
        content_tag(
          'label',
          check_box_tag(
            'project_type[tracker_ids][]',
            value,
            @project_type.tracker_assigned?(value),
            id: nil
          ) + text.to_s,
          class: 'floating'
        )
      end.join.html_safe
  end

  def available_issue_trackers
    Tracker.sorted.collect { |t| [t.name, t.id.to_s] }
  end
end
