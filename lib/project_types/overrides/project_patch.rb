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
  module Overrides
    # Patches project.rb from Redmine Core
    module ProjectPatch
      def self.prepended(base)
        base.singleton_class.prepend(ClassMethods)
        base.prepend(InstanceMethods)
      end

      module ClassMethods
        ##
        # Extends with project custom fields.
        #
        # @override Project#copy_from
        #
        def copy_from(project)
          copy = super(project)
          project = project.is_a?(Project) ? project : Project.find(project)
          copy.project_custom_fields = project.project_custom_fields
          copy
        end
      end

      module InstanceMethods
        ##
        # Sorts out fields not belonging to current project or project type.
        #
        # @override Project#visible_custom_field_values
        #
        def visible_custom_field_values(user = nil)
          ids = project_custom_field_ids
          return super if new_record? && ids.empty?

          user ||= User.current
          custom_field_values.select do |value|
            next unless ids.include? value.custom_field.id

            value.custom_field.visible_by?(project, user)
          end
        end
      end
    end
  end
end

# Apply patch
Rails.configuration.to_prepare do
  unless Project.included_modules.include?(ProjectTypes::Overrides::ProjectPatch)
    Project.prepend ProjectTypes::Overrides::ProjectPatch
  end
end
