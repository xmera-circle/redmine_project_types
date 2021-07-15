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

##
# Defines the most important associations of a project type.
# All other associations are defined on project level in order
# to use the projects structure through out the application,
# e.g. Controller, Views.
#
class ProjectType < Project
  before_destroy :nullify_project_type_id

  has_many :relatives, -> { where(status: STATUS_ACTIVE) },
           class_name: 'Project',
           inverse_of: :project_type

  scope :masters, -> { where(is_project_type: true).sorted }

  def self.masters_for_select
    masters.active.select(:name, :id)
  end

  def self.masters_for_table
    ProjectType.masters.status(@status).sorted
  end

  def self.fields_for_order_statement(table=nil)
    table ||= table_name
    columns = ['name']
    columns.uniq.map { |field| "#{table}.#{field}" }
  end

  private

  def nullify_project_type_id
    return unless relatives.present?

    relatives.each { |relative| relative.update_attribute(:project_type_id, nil) }
  end
end
