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

class Relatives
  def initialize(project)
    @project = project
  end

  ##
  # Find all relatives depending on whether the project is a project type master.
  #
  # @note A project type master would not be found if it is a new record.
  #   Consequently, it can't have relatives. Using relatives on a plain project
  #   returns an empty array. See Project#relatives in ProjectPatch.
  #
  def all
    project.new_record? ? project.relatives : project_type.relatives
  end

  def count
    all.count
  end

  private

  attr_reader :project

  ##
  # Tries to find the project type
  #
  # @return [ProjectType, nil] Nil if there is no project type master.
  #
  def project_type
    ProjectType.masters.find_by(id: project.id)
  end
end
