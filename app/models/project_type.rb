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
  has_many :projects, autosave: true
  has_many :enabled_modules, -> { where 'project_type_id != ?', nil }, :dependent => :delete_all

  # has_many :trackers, :through => :project_types_default_trackers
  # has_many :project_types_default_trackers, :dependent => :delete_all 
  # has_many :project_types_default_modules, :dependent => :delete_all
  # has_many :issue_custom_fields, :through => :trackers
    

  validates_presence_of :name
  validates_uniqueness_of :name

  acts_as_positioned

  scope :sorted, lambda { order(:position) }

  # unused
  def <=>(project_type)
    position <=> project_type.position
  end
  
  # unused
  def self.relation_order
    self.sorted.to_a
  end

  safe_attributes(
    :name,
    :description,
    :identifier,
    :is_public,
    :default_member_role_id,
    :position,
    :enabled_module_names)

  def is_public?
    is_public
  end

  def default_member_role
    Role.givable.find_by_id(default_member_role_id) || Role.givable.first
  end

  ##############################################################################
  # Return the enabled module with the given name
  # or nil if the module is not enabled for the project
  def enabled_module(name)
    name = name.to_s
    byebug
    enabled_modules.detect {|m| m.name == name}
  end

  # Return true if the module with the given name is enabled
  def module_enabled?(name)
    enabled_module(name).present?
  end
################################################################################
  def enabled_module_names=(module_names)
    if module_names && module_names.is_a?(Array)
      module_names = module_names.collect(&:to_s).reject(&:blank?)
      self.enabled_modules = module_names.collect {|name| enabled_modules.detect {|mod| mod.name == name} || EnabledModule.new(:name => name)}
    else
      enabled_modules.clear
    end
  end

  # Returns an array of the enabled modules names
  def enabled_module_names
    enabled_modules.collect(&:name)
  end

  # Enable a specific module
  #
  # Examples:
  #   project.enable_module!(:issue_tracking)
  #   project.enable_module!("issue_tracking")
  def enable_module!(name)
    enabled_modules << EnabledModule.new(:name => name.to_s) unless module_enabled?(name)
  end

  # Disable a module if it exists
  #
  # Examples:
  #   project.disable_module!(:issue_tracking)
  #   project.disable_module!("issue_tracking")
  #   project.disable_module!(project.enabled_modules.first)
  def disable_module!(target)
    target = enabled_modules.detect{|mod| target.to_s == mod.name} unless enabled_modules.include?(target)
    target.destroy unless target.blank?
  end
end
