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

class CreateProjectTypesTrackers < ActiveRecord::Migration[4.2]
  def self.up
    create_table :project_types_trackers, id: false do |t|
      t.column :project_type_id, :integer, default: 0, null: false
      t.column :tracker_id, :integer, default: 0, null: false
    end
    add_index :project_types_trackers, %i[project_type_id tracker_id], name: :project_types_trackers_unique,
                                                                       unique: true
  end

  def self.down
    drop_table :project_types_trackers
  end
end
