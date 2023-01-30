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
    module ProjectCustomFieldPatch
      def self.prepended(base)
        base.prepend(InstanceMethods)
      end

      module InstanceMethods
        ##
        # Validate only those project custom fields which belong to the
        # project. Values of fields don't belonging to the underlying project (type)
        # are ignored. Values of projects having no project type are validated
        # as in a default Redmine instance.
        #
        # @override CustomField#validate_custom_value
        #
        # Returns the error messages for the given value
        # or an empty array if value is a valid value for the custom field
        def validate_custom_value(custom_value)
          return [] if nothing_to_validate?(custom_value) || not_project_custom_field?(custom_value)

          super
        end
      end
    end
  end
end
