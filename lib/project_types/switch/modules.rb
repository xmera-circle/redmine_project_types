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
    module Modules
      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods
        def enabled_modules
          unless self.included_modules.include?(ProjectTypes::Switch::Modules::Association)
            send :prepend, ProjectTypes::Switch::Modules::Association
          end
          unless self.included_modules.include?(ProjectTypes::Switch::Modules::InstanceMethods)
            send :include, ProjectTypes::Switch::Modules::InstanceMethods    
          end

          belongs_to :project_type
          ##
          # Redirects the EnabledModule association to be dependent
          # on the project_type_id instead of project_id.
          # That is, all requests are transferred through the ProjectType model.
          #
          has_many :project_type_modules, 
                    class_name: 'EnabledProjectTypeModule', 
                    foreign_key: :project_type_id,
                    through: :project_type,
                    source: :enabled_modules
  
          ##
          # Since ProjectType model is now responsible for some configuration
          # the respective methods are delegated to it. Delegating to 
          # enabled_modules will take place by super as defined below.
          #
          # @note: Some delegations might meanwhile be redundant since enabled
          #   modules are synchronised. This should be checked and revised. The
          #   respective methods which might be eliminated are in 
          #   ProjectTypes::Association::Modules module.
          #
          delegate :is_public,
                  :is_public?, 
                  :default_member_role,
                  :enabled_modules,
                  :enabled_module_names,
                  :enabled_module_names=,
                  :enabled_module,
                  :module_enabled?,
                  :enable_module!,
                  :disable_module!,
                  :synchronise_modules,
                  :synchronise_projects_trackers,
                  :synchronise_custom_fields_projects,
                  to: :project_type, 
                  allow_nil: true

          safe_attributes :project_type_id
          delete_safe_attribute_names :is_public, 
                                      :enabled_module_names, 
                                      :tracker_ids
        end
      end

      ##
      # This module overrides Project#enabled_modules, where super refers to
      # the original method which again is delegated to 
      # ProjectType#enabled_modules as defined above.
      #
      module Association
        ##
        # If there is a project_type_id the association is redirected via 
        # ProjectType model to get the enabled modules. If no project_type_id
        # exist, the linkage is made manually what gives an empty 
        # ActiveRecord::Association::CollectionProxy instead of nil
        # 
        # @return [ActiveRecord::Association::CollectionProxy]
        #
        def enabled_modules
          project_type_id ? super : self.project_type_modules
        end
      end

      module InstanceMethods
        def self.included(base)
          base.extend ClassMethods
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