# frozen_string_literal: true
#
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
  module Switch
    module Trackers
      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods
        def trackers
          unless self.included_modules.include?(ProjectTypes::Switch::Trackers::InstanceMethods)
            send :include, ProjectTypes::Switch::Trackers::InstanceMethods    
          end
          unless self.reflect_on_association(:project_types)
            has_and_belongs_to_many :project_types,
                                    autosave: true,
                                    after_add: :add_projects_tracker,
                                    after_remove: :remove_projects_tracker

            safe_attributes :project_type_ids
            delete_safe_attribute_names :project_ids
          end
        end
      end

      module InstanceMethods
        def self.included(base)
          base.extend ClassMethods
        end

        def add_projects_tracker(project_type)
          project_type. synchronise_projects_tracker(self)
        end

        def remove_projects_tracker(project_type)
          project_type. synchronise_projects_tracker(self)
        end

        module ClassMethods
          ##
          # Attributes handled by the projects project_type are not allowed
          # to manipulate in the project directly.
          #
          # @note: @safe_attributes is a nested array with 3 levels:
          #   [[[list], {option}], [[list], {option}], ...] where list contains
          #   the names of the safe attributes.
          #
          def delete_safe_attribute_names(*args)
            return if args.empty?
            attributes = []
            @safe_attributes.collect do |elements, options|
              args.each do |name|
                elements.delete(name.to_s)
              end
              attributes << [elements, options] unless elements.empty?
            end
            @safe_attributes = attributes
          end
        end
      end
    end
  end
end