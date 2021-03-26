# frozen_string_literal: true

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

class Redmine::ApiTest::ProjectsTest
  original_test = instance_method("test_GET_/projects/:id.xml_should_return_the_project")

  define_method("test_GET_/projects/:id.xml_should_return_the_project") do

    project = Project.find(1)
    project.inherit_members = 1
    project.project_custom_field_ids = [3]
    project.save!

    original_test.bind(self).()
  end
end