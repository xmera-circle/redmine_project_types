# Redmine plugin for xmera called Project Types Plugin.
#
# Copyright (C) 2017-19 Liane Hampe <liane.hampe@xmera.de>.
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

class AddIndexToProjectsProjectTypes < ActiveRecord::Migration[4.2]
  def self.up   
    add_index :projects_project_types, :project_id, unique: true unless index_exists?(:projects_project_types, :project_id)
    add_index :projects_project_types, :project_type_id unless index_exists?(:projects_project_types, :project_type_id)
  end
  
  def self.down
    remove_index :projects_project_types, :project_id if index_exists?(:projects_project_types, :project_id)
    remove_index :projects_project_types, :project_type_id if index_exists?(:projects_project_types, :project_type_id)
  end
end
