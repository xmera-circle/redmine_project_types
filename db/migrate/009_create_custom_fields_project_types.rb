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

class CreateCustomFieldsProjectTypes < ActiveRecord::Migration[4.2]
  def self.up
    create_table :custom_fields_project_types, id: false do |t|
      t.column :custom_field_id, :integer, default: 0, null: false
      t.column :project_type_id, :integer, default: 0, null: false
    end
    add_index :custom_fields_project_types, 
              [:custom_field_id, :project_type_id], 
              unique: true,
              name: :index_cf_pt_on_cf_id_and_pt_id
  end

  def self.down
    drop_table :custom_fields_project_types
  end
end