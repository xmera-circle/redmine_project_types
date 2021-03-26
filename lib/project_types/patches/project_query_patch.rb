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

module ProjectTypes
  module Patches
    # Patches project_query.rb from Redmine Core
    module ProjectQueryPatch
      def self.prepended(base)
        base.extend(ClassMethods)
        base.prepend(InstanceMethods)
        base.class_eval do
          self.available_columns.append(project_type_column)
        end
      end

      module ClassMethods
        ##
        # Adds the project_type attribute to be available as column in the 
        # project query.
        #
        #
        def project_type_column
          QueryAssociationColumn.new(:project_type,
                                     :name,
                                      sortable:  "#{Project.table_name}.project_type_id",
                                      caption: :label_project_type)
        end
      end

      module InstanceMethods

        ##
        # @override ProjectQuery#initialize
        #
        def initialize(attributes=nil, *args)
          super attributes
          self.filters.merge!({ 'is_project_type' => {operator: "=", values: ["0"]} })
        end

        ##
        # @override ProjectQuery#initialize_available_filters
        #
        def initialize_available_filters
          super
          add_available_filter(
            'project_type_id',
            :type => :list_subprojects, :values => lambda { project_type_values }, :label => :label_project_type
          )
          add_available_filter(
            'is_project_type',
            type: :list,
            values: [[l(:general_text_yes), "1"], [l(:general_text_no), "0"]],
            label: :label_project_type_master
          )
        end

        def project_type_values
          ProjectType.projects.pluck(:name, :id).map {|name, id| [name, id.to_s] }
        end
      end
    end
  end
end

# Apply patch
Rails.configuration.to_prepare do
  unless ProjectQuery.included_modules.include?(ProjectTypes::Patches::ProjectQueryPatch)
    ProjectQuery.prepend ProjectTypes::Patches::ProjectQueryPatch
  end
end
