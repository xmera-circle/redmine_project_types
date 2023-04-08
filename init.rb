# frozen_string_literal: true

#
# Redmine plugin for xmera called Project Types Plugin.
#
# Copyright (C) 2017-2023 Liane Hampe <liaham@xmera.de>, xmera Solutions GmbH.
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

require File.expand_path('lib/project_types', __dir__)

Redmine::Plugin.register :redmine_project_types do
  name 'Redmine Project Types'
  author 'Liane Hampe, xmera Solutions GmbH'
  description 'This is a plugin for defining project types with individual project default settings.'
  version '4.2.3'
  url 'https://circle.xmera.de/projects/redmine-project-types'
  author_url 'https://circle.xmera.de/users/5'

  requires_redmine version_or_higher: '4.1.1'
  requires_redmine_plugin :redmine_base_deface, version_or_higher: '1.6.2'
  requires_redmine_plugin :advanced_plugin_helper, version_or_higher: '0.4.0'

  menu :admin_menu, :project_types, { controller: 'project_types', action: 'index' },
       caption: :label_project_type_plural,
       html: { class: 'icon icon-types' },
       first: true
end

ProjectTypes.setup
