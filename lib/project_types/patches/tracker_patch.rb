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
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA

module ProjectTypes
  module Patches
    module TrackerPatch
      def self.prepended(base)
        base.extend(ClassMethods)
        base.include(InstanceMethods)
        base.class_eval do
          include ProjectTypes::Switch::Trackers
          after_initialize do
            enable_switch(:trackers) if ProjectTypes.any?
          end
        end
      end

      module ClassMethods
        def enable_switch(name)
          send name
        end
      end

      module InstanceMethods
        def enable_switch(name)
          self.class.enable_switch(name)
        end
      end
    end
  end
end

# Apply patch
Rails.configuration.to_prepare do
  unless Tracker.included_modules.include?(ProjectTypes::Patches::TrackerPatch)
    Tracker.prepend(ProjectTypes::Patches::TrackerPatch)
  end
end
