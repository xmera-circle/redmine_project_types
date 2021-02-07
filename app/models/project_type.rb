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
  include ProjectTypes::Association::Modules
  include ProjectTypes::Association::Trackers
  include ProjectTypes::Synchronisation::Modules
  include ProjectTypes::Synchronisation::Trackers
  include ProjectTypes::Synchronisation::IssueCustomFields

  has_many :projects, autosave: true
  has_many :enabled_modules,
           class_name: 'EnabledProjectTypeModule', 
           :dependent => :delete_all
  has_and_belongs_to_many :trackers, 
                          lambda {order(:position)},
                          autosave: true
  has_and_belongs_to_many :issue_custom_fields,
                          lambda {order(:position)},
                          class_name: 'IssueCustomField',
                          join_table: "#{table_name_prefix}custom_fields_project_types#{table_name_suffix}",
                          association_foreign_key: 'custom_field_id'

  validates_presence_of :name
  validates_uniqueness_of :name

  after_commit do |project_type|
    project_type.synchronise_modules
    project_type.synchronise_projects_trackers
    project_type.synchronise_issue_custom_fields_projects
  end

  acts_as_positioned

  scope :sorted, lambda { order(:position) }

  ##
  # Same as for Project class. That is, all global project settings will
  # now be applied to project types. Exception is the project identifier which
  # should be kept globally for simplicity.
  #
  def initialize(attributes=nil, *args)
    super

    initialized = (attributes || {}).stringify_keys
    if !initialized.key?('is_public')
      self.is_public = default_project_public
    end
    if !initialized.key?('enabled_module_names')
      self.enabled_module_names = default_project_modules
    end
    if !initialized.key?('trackers') && !initialized.key?('tracker_ids')
      default = default_project_trackers
      if default.is_a?(Array)
        self.trackers = Tracker.where(:id => default.map(&:to_i)).sorted.to_a
      else
        self.trackers = Tracker.sorted.to_a
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
    :issue_custom_field_ids)

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
      raise "Unable to create the system project type (#{project_type.errors.full_messages.join(',')})." if project_type.new_record?
    end
    project_type
  end
  private_class_method :find_or_create_system_project_type
end
