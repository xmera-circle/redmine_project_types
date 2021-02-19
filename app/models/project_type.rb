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

class ProjectType < ActiveRecord::Base
  include Redmine::SafeAttributes
  include Redmine::I18n
  include ProjectTypes::Associations::Modules
  include ProjectTypes::Associations::Trackers
  include ProjectTypes::Synchronisation::Modules
  include ProjectTypes::Synchronisation::Trackers
  include ProjectTypes::Synchronisation::IssueCustomFields

  has_many :projects, autosave: true

  has_many :enabled_modules,
           class_name: 'EnabledProjectTypeModule',
           dependent: :delete_all

  has_and_belongs_to_many :trackers,
                          -> { order(:position) },
                          autosave: true

  has_and_belongs_to_many :issue_custom_fields,
                          -> { order(:position) },
                          class_name: 'IssueCustomField',
                          join_table: "#{table_name_prefix}custom_fields_project_types#{table_name_suffix}",
                          association_foreign_key: 'custom_field_id'

  has_and_belongs_to_many :project_custom_fields,
                          -> { order(:position) },
                          class_name: 'ProjectCustomField',
                          join_table: "#{table_name_prefix}custom_fields_project_types#{table_name_suffix}",
                          association_foreign_key: 'custom_field_id',
                          before_remove: :integrity_of_project_custom_fields

  validates_presence_of :name
  validates_uniqueness_of :name

  after_commit do |project_type|
    project_type.synchronise_modules
    project_type.synchronise_projects_trackers
    project_type.synchronise_issue_custom_fields_projects
  end

  acts_as_positioned

  scope :sorted, -> { order(:position) }

  ##
  # Same as for Project class. That is, all global project settings will
  # now be applied to project types. Exception is the project identifier which
  # should be kept globally for simplicity.
  #
  def initialize(attributes = nil, *args)
    super

    initialized = (attributes || {}).stringify_keys
    self.is_public = default_project_public unless initialized.key?('is_public')
    self.enabled_module_names = default_project_modules unless initialized.key?('enabled_module_names')
    if !initialized.key?('trackers') && !initialized.key?('tracker_ids')
      default = default_project_trackers
      self.trackers = if default.is_a?(Array)
                        Tracker.where(id: default.map(&:to_i)).sorted.to_a
                      else
                        Tracker.sorted.to_a
                      end
    end
  end

  safe_attributes(
    :name,
    :description,
    :identifier,
    :is_public,
    :default_member_role_id,
    :position,
    :enabled_module_names,
    :tracker_ids,
    :issue_custom_field_ids,
    :project_custom_field_ids
  )

  def is_public?
    is_public
  end

  def default_member_role
    Role.givable.find_by_id(default_member_role_id) || Role.givable.first
  end

  def default_project_modules
    Setting.default_projects_modules
  end

  def default_project_public
    Setting.default_projects_public
  end

  def default_project_trackers
    Setting.default_projects_tracker_ids
  end

  ##
  # This check raises an error if there are project custom fiels having projects
  # assigned which again have values in the respective field.
  #
  def integrity_of_project_custom_fields(project_custom_field, error_object: nil)
    return unless ProjectTypes.any? || projects.any?

    current_object = error_object || self
    pairs = project_custom_field.custom_values.collect { |val| [val.customized_id, val.value] unless val.nil? }
    values_found = pairs.select { |pair| project_ids.include?(pair[0]) && pair[1].present? }

    return unless values_found.present?

    current_object.errors.add :base, l(:error_project_custom_field_has_projects_assigned, count: values_found.size)
    raise ActiveModel::ValidationError, current_object
  end

  # unused
  def self.fallback_id
    project_type = find_or_create_system_project_type
    project_type.id
  end

  # unused
  def self.find_or_create_system_project_type
    name = 'system default project type'
    project_type = unscoped.find_by(name: name)
    if project_type.nil?
      project_type = unscoped.create(name: name) do |type|
        type.enabled_module_names = type.default_project_modules
        type.is_public = type.default_project_public
      end
      if project_type.new_record?
        raise "Unable to create the system project type (#{project_type.errors.full_messages.join(',')})."
      end
    end
    project_type
  end
  private_class_method :find_or_create_system_project_type
end
