# frozen_string_literal: true

#
# Redmine plugin for xmera called Project Types Plugin.
#
# Copyright (C) 2017 - 2022 Liane Hampe <liaham@xmera.de>, xmera.
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

class AddIsProjectTypeToProjects < ActiveRecord::Migration[4.2]
  def self.up
    add_column :projects, :is_project_type, :boolean, default: false, null: false unless column_exists?(:projects,
                                                                                                        :is_project_type)
    add_index :projects, :is_project_type unless index_exists?(:projects, :is_project_type)
  end

  def self.down
    remove_index :projects, :is_project_type if index_exists?(:projects, :is_project_type)
    remove_column :projects, :is_project_type if column_exists?(:projects, :is_project_type)
  end
end
