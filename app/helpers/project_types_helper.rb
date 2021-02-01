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
 def modules_multiselect(project_type_id, choices, options={})
    hidden_field_tag("project_type[enabled_module_names][]", '').html_safe +
    choices.collect do |choice|
      text, value = (choice.is_a?(Array) ? choice : [choice, choice])
      content_tag(
        'label',
        check_box_tag(
            "project_type[enabled_module_names][]",
            value,
            @project_type.module_enabled?(value),
            :id => nil
          ) + text.to_s,
        :class => 'floating'
        )
    end.join.html_safe
  end
  
  def trackers_multiselect(project_type_id, choices, label,options={})
    
    trackers = ProjectTypesDefaultTracker.where(project_type_id: project_type_id).pluck(:tracker_id)
    trackers = [] unless trackers.is_a?(Array)

    content_tag("label", l(label) ) +
      hidden_field_tag("project_types_tracker[tracker_id][]", '').html_safe +
      choices.collect do |choice|
        text, value = (choice.is_a?(Array) ? choice : [choice, choice])
        content_tag(
          'label',
          check_box_tag(
             "project_types_tracker[tracker_id][]",
             value,
             trackers.include?(value),
             :id => nil
           ) + text.to_s,
          :class => 'block'
         )
      end.join.html_safe
  end
  
  def create_multi_modules(record_set, parameters)
    record_set.delete_all
      
        parameters[:name].each do |i|
            if !i.empty?
              record_set.create!( name: i)
            end
        end
  end
  
  def create_multi_trackers(record_set, parameters)
    record_set.delete_all
      
        parameters[:tracker_id].each do |i|
            if !i.empty?
              record_set.create!( tracker_id: i)
            end
        end
  end

  def available_project_modules
    Redmine::AccessControl.available_project_modules.collect {|m| [l_or_humanize(m, :prefix => "project_module_"), m.to_s] }
  end
end
