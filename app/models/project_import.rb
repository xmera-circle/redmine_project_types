# frozen_string_literal: true

#
# Redmine plugin for xmera called Project Types Plugin.
#
# Copyright (C) 2022 Liane Hampe <liaham@xmera.de>, xmera.
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

class ProjectImport < Import
  AUTO_MAPPABLE_FIELDS = {
    'name' => 'field_name',
    'description' => 'field_description',
    'identifier' => 'field_identifier',
    'is_public' => 'field_is_public',
    'parent' => 'field_parent',
    'inherit_members' => 'field_inherit_members',
    'project_type' => 'field_project_type'
  }.freeze

  def self.authorized?(user)
    user.allowed_to?(:import_projects, nil, global: true)
  end

  def self.menu_item
    :projects
  end

  def saved_objects
    Project.where(id: saved_items.pluck(:obj_id)).order(:id)
  end

  def mappable_custom_fields
    ProjectCustomField.all
  end

  private

  def build_object(row, _item)
    find = finder_attributes(row)
    return ImportErrorObject.new(identifier: false) unless find

    parent, project_type = found_objects(find)
    return ImportErrorObject.new(project_type: false) unless project_type

    required = required_attributes(row)
    attributes = object_attributes(row, parent, project_type)
    object = Project.new(attributes.merge(required))

    return ImportErrorObject.new(custom_fields: false) unless all_pcf_found?(object)

    object = copy_associations(object, project_type, row)
    object.copy(project_type)
    object
  end

  def finder_attributes(row)
    parent = check_identifier(row_value(row, 'parent'))
    project_type = check_identifier(row_value(row, 'project_type'))

    return unless parent && project_type

    {
      parent: parent,
      project_type: project_type
    }
  end

  ##
  # Checks whether the identifier follows the rules for projects identifiers:
  # downcase letters, digits, dashes but not digits only.
  #
  # @see Project.validates_format_of
  #
  def check_identifier(identifier)
    result = identifier.match(/\A(?!\d+$)[a-z0-9\-_]*\z/)
    result&.to_s
  end

  def found_objects(attr)
    parent = parent_project_find_by(identifier: attr[:parent])
    project_type = ProjectType.find_by(identifier: attr[:project_type])
    [parent, project_type]
  end

  def parent_project_find_by(identifier:)
    Project.find_by(identifier: identifier)
  end

  def required_attributes(row)
    {
      name: row_value(row, 'name'),
      identifier: row_value(row, 'identifier')
    }
  end

  def object_attributes(row, parent, project_type)
    {
      description: row_value(row, 'description'),
      is_public: row_value(row, 'is_public'),
      inherit_members: row_value(row, 'inherit_members'),
      parent: parent,
      project_type: project_type
    }
  end

  def copy_associations(target, source, row)
    target.enabled_module_names = source.enabled_module_names
    target.trackers = source.trackers
    target.custom_values = source.custom_values.collect(&:clone)
    target.issue_custom_fields = source.issue_custom_fields
    target.project_custom_fields = source.project_custom_fields
    target.custom_fields = project_custom_field_values(row, target)
    target
  end

  def project_custom_field_values(row, object)
    project_custom_fields(object).map do |pcf|
      field = pcf.custom_field
      case field.field_format
      when 'date'
        { id: field.id, value: row_date(row, "cf_#{field.id}") }
      else
        { id: field.id, value: row_value(row, "cf_#{field.id}") }
      end
    end
  end

  def num_of_pcf_found(object)
    project_custom_fields(object).count
  end

  def project_custom_fields(object)
    object.visible_custom_field_values.select do |pcf|
      pcf_names.include?(pcf.custom_field.name) ||
        humanized_pcf_names.include?(pcf.custom_field.name)
    end
  end

  def all_pcf_found?(object)
    (number_of_pcf_columns - num_of_pcf_found(object)).zero?
  end

  def pcf_names
    @pcf_names ||= pcf_columns_options.map(&:first)
  end

  def humanized_pcf_names
    pcf_names.map do |name|
      l_or_humanize(name)
    end
  end

  def number_of_pcf_columns
    pcf_columns_options.count
  end

  ##
  # Selects project custom field names with their index in a row.
  #
  # @return [Array(Array(String, Integer))] A list of arrays where each holds
  #                                         the pcf name and index.
  # @example
  # [["Project Type Master", 6], ["Responsible Person", 7], ...]
  #
  #
  def pcf_columns_options
    @pcf_columns_options ||= columns_options.reject do |option, _index|
      AUTO_MAPPABLE_FIELDS.value?(language_key(option).to_s) ||
        AUTO_MAPPABLE_FIELDS.key?(option.to_s)
    end
  end

  def language_key(translation)
    find_field(translation)
  end

  ##
  # Reverse look up of translation keys.
  #
  # @return [Array(Array(Symbol, Integer))] A list of arrays where each holds
  #                                         the key and index.
  # @example
  # [[:field_name, 0], [:field_description, 1], ...]
  #
  def columns_option_keys
    columns_options.map do |option, index|
      key = find_field(option)
      [key, index] if key.present?
    end
  end

  def find_field(name)
    I18n
      .backend
      .translations[current_language]
      .select { |_, value| value == name } # in case there are muliple keys for that translation name
      .keys
      .find { |field| field.start_with? 'field' }
  end

  def extend_object(_row, _item, object)
    object.add_default_member(User.current) unless User.current.admin?
  end
end
