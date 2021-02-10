# frozen_string_literal: true

#
# Redmine plugin for xmera called Project Types Plugin.
#
# Copyright (C) 2017-2021 Liane Hampe <liaham@xmera.de>, xmera.
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

class CreateEnabledProjectTypeModules < ActiveRecord::Migration[4.2]
  def self.up
    unless table_exists?(:enabled_project_type_modules)
      create_table :enabled_project_type_modules do |t|
        t.string :name, null: false
        t.integer :project_type_id
        t.index [:project_type_id], name: :enabled_project_type_modules_project_type_id
      end
    end
  end

  def self.down
    drop_table :enabled_project_type_modules if table_exists?(:enabled_project_type_modules)
  end
end
