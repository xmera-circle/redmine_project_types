# frozen_string_literal: true

#
# Redmine plugin for xmera called Project Types Plugin.
#
# Copyright (C) 2017-2023 Liane Hampe <liaham@xmera.de>, xmera Solutions GmbH.
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
  module Overrides
    # Patches projects_controller.rb from Redmine Core
    module ApplicationHelperPatch
      def self.prepended(base)
        base.prepend(InstanceMethods)
      end

      module InstanceMethods
        ##
        # Add project name suffix to mark project type master.
        #
        # @override ApplicationHelper#project_tree_options_for_select
        #
        def project_tree_options_for_select(projects, options = {})
          s = ''.html_safe
          if blank_text = options[:include_blank]
            blank_text = '&nbsp;'.html_safe if blank_text == true
            s << content_tag('option', blank_text, value: '')
          end
          project_tree(projects) do |project, level|
            name_prefix = (level.positive? ? "#{'&nbsp;' * 2 * level}&#187; " : '').html_safe
            name_suffix = project.is_project_type? ? l(:label_suffix_project_type_master_identifier) : ''
            tag_options = { value: project.id }
            tag_options[:selected] = if project == options[:selected] || (options[:selected].respond_to?(:include?) &&
                options[:selected].include?(project))
                                       'selected'
                                     end
            tag_options.merge!(yield(project)) if block_given?
            s << content_tag('option', name_prefix + h(project) + name_suffix, tag_options)
          end
          s.html_safe
        end
      end
    end
  end
end
