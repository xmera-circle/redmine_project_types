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

module ProjectTypes
  module Patches
    # Patches projects_controller.rb from Redmine Core
    module AdminControllerPatch
      def self.prepended(base)
        base.prepend(InstanceMethods)
      end

      module InstanceMethods
        include Redmine::Pagination
        
        def projects
          @status = params[:status] || 1

          scope = Project.projects.status(@status).sorted
          scope = scope.like(params[:name]) if params[:name].present?

          @project_count = scope.count
          @project_pages = Paginator.new @project_count, per_page_option, params['page']
          @projects = scope.limit(@project_pages.per_page).offset(@project_pages.offset).to_a

          render :action => "projects", :layout => false if request.xhr?
        end
      end
    end
  end
end

# Apply patch
Rails.configuration.to_prepare do
  unless AdminController.included_modules.include?(ProjectTypes::Patches::AdminControllerPatch)
    AdminController.prepend ProjectTypes::Patches::AdminControllerPatch
  end
end
