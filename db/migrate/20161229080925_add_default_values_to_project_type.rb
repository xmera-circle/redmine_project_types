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

class AddDefaultValuesToProjectType < ActiveRecord::Migration
  def self.up
    add_column :project_types, :is_public, :boolean, :default => false, :null => false
    add_column :project_types, :default_user_role_id, :integer, foreign_key: true
  end
  
  def self.down
    remove_column :project_types, :is_public
    remove_column :project_types, :default_user_role_id
  end
end