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

  belongs_to :master, 
              class_name: 'MasterProject', 
              foreign_key: :master_project_id, autosave: true

  delegate :is_public?, to: :master, allow_nil: true
  delegate :parent, to: :master, prefix: :master
 
  validates_presence_of :name
  validates_uniqueness_of :name

  after_commit do |project_type|
    project_type.send :update_master
  end

  acts_as_positioned

  scope :sorted, -> { order(:position) }

  safe_attributes(
    :name,
    :description,
    :position,
    :master_project_id
  )

  private

  def update_master
    return if self.master && name_unchanged? 

    if self.master
      self.master.update_attributes(master_attributes)
    else
      self.master = create_master_project
      save
    end
  end

  def create_master_project
    create_master(master_attributes)
  end

  def master_attributes
    { name: self.name,
      identifier: master_identifier,
      parent_id: MasterProject.master_parent.id,
      project_type_id: self.id }
  end

  def name_unchanged?
    !saved_change_to_name? 
  end

  def master_identifier
    name.parameterize
  end
end
