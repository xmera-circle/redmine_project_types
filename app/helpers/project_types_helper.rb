# Redmine plugin for xmera:isms called Project Types Plugin
#
# Copyright (C) 2017-18 Liane Hampe <liane.hampe@xmera.de>
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
 def default_modules_multiselect(project_type_id, choices, label,options={})
    
    default_modules = ProjectTypesDefaultModule.where(project_type_id: project_type_id).pluck(:name)
    default_modules = [] unless default_modules.is_a?(Array)

    content_tag("label", l(label) ) +
      hidden_field_tag("project_types_default_module[name][]", '').html_safe +
      choices.collect do |choice|
        text, value = (choice.is_a?(Array) ? choice : [choice, choice])
        content_tag(
          'label',
          check_box_tag(
             "project_types_default_module[name][]",
             value,
             default_modules.include?(value),
             :id => nil
           ) + text.to_s,
          :class => 'block'
         )
      end.join.html_safe
  end
  
  def default_trackers_multiselect(project_type_id, choices, label,options={})
    
    default_trackers = ProjectTypesDefaultTracker.where(project_type_id: project_type_id).pluck(:tracker_id)
    default_trackers = [] unless default_trackers.is_a?(Array)

    content_tag("label", l(label) ) +
      hidden_field_tag("project_types_default_tracker[tracker_id][]", '').html_safe +
      choices.collect do |choice|
        text, value = (choice.is_a?(Array) ? choice : [choice, choice])
        content_tag(
          'label',
          check_box_tag(
             "project_types_default_tracker[tracker_id][]",
             value,
             default_trackers.include?(value),
             :id => nil
           ) + text.to_s,
          :class => 'block'
         )
      end.join.html_safe
  end
  
  def create_multi_default_modules(record_set, parameters)
    record_set.delete_all
      
        parameters[:name].each do |i|
            if !i.empty?
              record_set.create!( name: i)
            end
        end
  end
  
  def create_multi_default_trackers(record_set, parameters)
    record_set.delete_all
      
        parameters[:tracker_id].each do |i|
            if !i.empty?
              record_set.create!( tracker_id: i)
            end
        end
  end
end
