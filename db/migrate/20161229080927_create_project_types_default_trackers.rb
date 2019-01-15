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

class CreateProjectTypesDefaultTrackers < ActiveRecord::Migration
  def self.up
    unless table_exists?(:project_types_default_trackers)
      create_table :project_types_default_trackers do |t|
        t.integer :project_type_id
        t.integer :tracker_id
      end
    end
  end
  
  def self.down
    if table_exists?(:project_types_default_trackers)
      drop_table :project_types_default_trackers
    end
  end
end
