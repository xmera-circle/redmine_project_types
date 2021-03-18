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

  has_many :projects

  has_one :master, 
          class_name: 'MasterProject',
          inverse_of: :project_type,
          autosave: true

  delegate :is_public?, to: :master, allow_nil: true
 
  validates_presence_of :name
  validates_uniqueness_of :name
  validates_uniqueness_of :is_master_parent, conditions: -> { where.not(is_master_parent: false) }

  after_commit :update_master, on: %i[create update]

  acts_as_positioned

  scope :sorted, -> { order(:position) }
  scope :without_master_parent, -> { where(is_master_parent: false) }

  def self.master_parent
    self.includes(:master).where(is_master_parent: true).take&.master
  end

  delegate :master_parent, to: :class
 
  safe_attributes(
    :name,
    :description,
    :position,
    :is_master_parent
  )

  def is_master_parent?
    self.is_master_parent
  end

  private

  def update_master
    return if self.master && name_unchanged?

    if self.master
      self.master.update_attributes(master_attributes)
    else
      create_master_project
    end
  end

  def name_unchanged?
    !saved_change_to_name? 
  end

  def master_parent_unchanged?
    !saved_change_to_is_master_parent?
  end

  def create_master_project
    master_project = build_master(master_attributes)
    unless master_project.valid?
      deleted = self.delete
      errors.add :master, master_project.errors.full_messages.join('/n')
      raise ActiveRecord::RecordInvalid, deleted
    end
    master_project.save
  end

  def master_attributes
    { name: self.name,
      identifier: master_identifier,
      parent_id: master_parent_id,
      project_type_id: self.id,
      is_master: true }
  end

  def master_identifier
    name.parameterize
  end

  def master_parent_id
    master_parent&.id
  end

end
