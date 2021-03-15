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

class MasterProject < Project

  class << self
    def of(project_type)
      name = project_type.name
      find_or_create_by(name: name, 
                        identifier: name.parameterize,
                        parent_id: master_parent.id)
    end

    def master_parent
      find_or_create_by(name: 'Masterobjekte',
                        identifier: name.parameterize)
    end
  end

  private
  
  def master_project?
    true
  end
end