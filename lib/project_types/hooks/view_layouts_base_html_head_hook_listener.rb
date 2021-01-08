# This file is part of Redmine Issue Cloning.
#
# Copyright (C) 2017-21 Liane Hampe <liaham@xmera.de>. xmera.
#
# Redmine Issue Cloning is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# Redmine Issue Cloning distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Redmine Issue Cloning; if not, see <http://www.gnu.org/licenses/>.


# Hooks the partial for new plugin and its CSS
class ViewLayoutsBaseHtmlHeadHookListener < Redmine::Hook::ViewListener
  render_on :view_layouts_base_html_head, partial: 'redmine_project_types/redmine_project_types_header_tags'
end
