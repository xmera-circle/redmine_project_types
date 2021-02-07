# frozen_string_literal: true
#
# Redmine plugin for xmera called Project Types Plugin..
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

# require_dependency 'project'

module ProjectTypes
  module Patches
    # Patches project.rb from Redmine Core
    module ProjectPatch
      def self.prepended(base)
        base.extend(ClassMethods)
        base.include(InstanceMethods) 
        base.class_eval do
          include ProjectTypes::Switch::Modules
                
          after_initialize do |project|
            enable_switch(:enabled_modules) if ProjectTypes.any?
          end

          after_commit do |project|
            if ProjectTypes.any?
              project.synchronise_modules 
              project.synchronise_projects_trackers
            end
          end 
        end
      end

      module ClassMethods
        ##
        # This switch will be checked only once. That is, the condition needs
        # to hold during the whole runtime. A change would not be considered.
        #
        # @note: Use this method interchangeable with the callback above!
        #
        def enable_switch(name)
          send name
        end
      end

      module InstanceMethods
        def enable_switch(name)
          self.class.enable_switch(name)
        end

        ##
        # Adds user as a project member with the default role of the project type.
        # Used when a non-admin user creates a project.
        #
        # @override This is overwritten from Project#add_default_member 
        #
        def add_default_member(user)
          return super(user) unless project_type_id.present?

          role = default_member_role
          member = Member.new(:project => self, :principal => user, :roles => [role])
          self.members << member
          member
        end
      end
    end
  end
end

# Apply patch
Rails.configuration.to_prepare do
  unless Project.included_modules.include?(ProjectTypes::Patches::ProjectPatch)
    Project.send(:prepend, ProjectTypes::Patches::ProjectPatch)
  end
end