# Redmine plugin for xmera:isms called Project Types Plugin
#
# Copyright (C) 2017-18 Liane Hampe <liane.hampe@xmera.de>
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
  unloadable
  
  # Associated models
  has_many :projects_project_types
  has_many :projects, :through => :projects_project_types
  
  has_many :trackers, :through => :project_types_default_trackers
  has_many :project_types_default_trackers, :dependent => :delete_all
  
  has_many :project_types_default_modules, :dependent => :delete_all
    
  # Validations
  validates_presence_of :name
  validates_uniqueness_of :name
  
  attr_protected :id
  acts_as_positioned

  scope :sorted, lambda { order(:position) }
  
  def <=>(project_type)
    position <=> project_type.position
  end
  
  def self.relation_order
    self.sorted.to_a
  end
  
end
