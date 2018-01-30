require 'redmine'

# Patches to the Redmine core
require 'project_patch'



ActionDispatch::Callbacks.to_prepare do
  Project.send :include, ProjectPatch unless Project.included_modules.include? ProjectPatch
end

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
