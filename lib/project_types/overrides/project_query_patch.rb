# frozen_string_literal: true

#
# Redmine plugin for xmera called Project Types Plugin.
#
# Copyright (C) 2017 - 2022 Liane Hampe <liaham@xmera.de>, xmera.
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
    # Patches project_query.rb from Redmine Core
    module ProjectQueryPatch
      def self.prepended(base)
        base.prepend(InstanceMethods)
      end

      module InstanceMethods
        ##
        # Sets a default filter for showing no project types masters.
        #
        # @override ProjectQuery#initialize
        #
        def initialize(attributes = nil, *_args)
          super attributes
          filters.merge!({ 'is_project_type' => { operator: '=', values: ['0'] } })
        end

        ##
        # Adds available filters for the new project attributes :project_type_id
        # and :is_project_type.
        #
        # @override ProjectQuery#initialize_available_filters
        #
        def initialize_available_filters
          super
          add_available_filter(
            'project_type_id',
            type: :list_subprojects, values: -> { project_type_values }, label: :label_project_type
          )
          add_available_filter(
            'is_project_type',
            type: :list,
            values: [[l(:general_text_yes), '1'], [l(:general_text_no), '0']],
            label: :label_project_type_master
          )
        end
      end
    end
  end
end

# Apply patch
Rails.configuration.to_prepare do
  unless ProjectQuery.included_modules.include?(ProjectTypes::Overrides::ProjectQueryPatch)
    ProjectQuery.prepend ProjectTypes::Overrides::ProjectQueryPatch
  end
end
