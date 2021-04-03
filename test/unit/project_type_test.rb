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

require File.expand_path("#{File.dirname(__FILE__)}/../test_helper")

class ProjectTypeTest < ActiveSupport::TestCase
  test 'should respond to projects' do
    assert ProjectType.respond_to? :projects
  end

  test 'should have many relatives' do
    association = ProjectType.reflect_on_association(:relatives)
    assert_equal :relatives, association.name
    assert_equal :has_many, association.macro
    assert_equal relatives_options, association&.options
  end

  private

  def relatives_options
    Hash({ class_name: 'Project',
           inverse_of: :project_type })
  end
end
