# frozen_string_literal: true

#
# Redmine plugin for xmera called Project Types Plugin.
#
# Copyright (C) 2022-2023 Liane Hampe <liaham@xmera.de>, xmera Solutions GmbH.
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

class ImportErrorObject
  extend ActiveModel::Naming
  include Redmine::I18n

  attr_accessor :project_type, :custom_fields, :identifier
  attr_reader :errors

  def initialize(project_type: true, custom_fields: true, identifier: true)
    @errors = ActiveModel::Errors.new(self)
    self.project_type = project_type
    self.custom_fields = custom_fields
    self.identifier = identifier
  end

  def id
    nil
  end

  def save
    validate!
    false
  end

  def validate!
    errors.add(:base, l(:error_no_project_type_given)) unless project_type
    errors.add(:base, l(:error_could_not_map_all_custom_fields)) unless custom_fields
    errors.add(:base, l(:error_identifer_not_valid)) unless identifier
  end

  def persisted?
    false
  end

  def read_attribute_for_validation(attr)
    send(attr)
  end

  def self.human_attribute_name(attr, _options = {})
    attr
  end

  def self.lookup_ancestors
    [self]
  end
end
