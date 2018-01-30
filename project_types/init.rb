# Redmine plugin for xmera:isms called Custom Footer Plugin
#
# Copyright (C) 2017-18 Liane Hampe <liane.hampe@xmera.de>
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

# Refers to the plugins list of requirements
require_dependency File.dirname(__FILE__) + '/lib/project_types.rb'

# Plugin registration
Redmine::Plugin.register :project_types do
  name 'Project Types Plugin'
  author 'Liane Hampe'
  description 'This is a plugin for defining project types with individual project default settings.'
  version '0.1.3'
  url 'http://example.com/path/to/plugin'
  author_url 'http://example.com/about'

  requires_redmine :version_or_higher => '3.3.2'
  
  settings :default => {
    
  }, :partial => 'settings/project_types_settings'
  
#  project_module :project_types do
#    permission :view_project_types, {:project_types => [:index, :show]}
#    permission :manage_project_types, {:project_types => [:index, :show, :new, :create, :destroy]}
#    permission :select_project_modules, {:project_types => :modules}, :require => :member
#  end
  
  menu :admin_menu, :project_types, { :controller => 'project_types', :action => 'index' }, :caption => :label_project_type_plural, :html => {:class => 'icon icon-plugins'}
end

# Adds the project types app/overrides directory to Rails'
# search paths for deface overrides
Rails.application.paths['app/overrides'] ||= []
project_types_overwrite_dir = "#{Redmine::Plugin.directory}/project_types/app/overrides".freeze
unless Rails.application.paths['app/overrides'].include?(project_types_overwrite_dir)
  Rails.application.paths['app/overrides'] << project_types_overwrite_dir
end
