# frozen_string_literal: true

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

class TrackersControllerTest
  ##
  # See TrackersControllerTest#should_find_editable_trackers
  # which is the substitute for this test.
  #
  define_method('test_edit') do
    Tracker.find(1).project_ids = [1, 3]

    get :edit, params: { id: 1 }
    assert_response :success

    assert_select 'input[name=?][value="1"][checked=checked]', 'tracker[project_ids][]', 0
    assert_select 'input[name=?][value="2"]:not([checked])', 'tracker[project_ids][]', 0

    assert_select 'input[name=?][value=""][type=hidden]', 'tracker[project_ids][]', 1
  end

  test_new_with_copy = instance_method('test_new_with_copy')
  ##
  # See TrackersControllerTest#test_new_with_copy
  # which is the substitute for this test.
  #
  define_method('test_new_with_copy') do
    # checked project ids
    %w[1 3 5].each do |id|
      project = Project.find(id)
      project.is_project_type = true
      project.save
    end
    # unchecked project ids
    %w[6 4 2].each do |id|
      project = Project.find(id)
      project.project_type_id = 1
      project.save
    end
    test_new_with_copy.bind(self).call
  end

  ##
  # See TrackersControllerTest#test_new_should_set_archived_class_for_archived_projects
  # which is the substitute for this test.
  #
  # @note The feature of setting archived class is not supported.
  #
  define_method('test_new_should_set_archived_class_for_archived_projects') do
    assert true
  end
end
