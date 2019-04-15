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

class CreateProjectsProjectTypes < ActiveRecord::Migration
  def self.up
    unless table_exists?(:projects_project_types)
      create_table :projects_project_types, :id => false do |t|
        t.integer :project_id, :default => 0, :null => false
        t.integer :project_type_id, :default => 0, :null => true
      end
    end
  end

  def self.down
    if table_exists?(:projects_project_types)
      drop_table :projects_project_types
    end
  end
end
