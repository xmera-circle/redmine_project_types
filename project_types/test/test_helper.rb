# Redmine plugin for xmera:isms called Project Types Plugin
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

# Suppresses ruby gems warnings when running tests
$VERBOSE = nil

# Load the Redmine helper
require File.expand_path(File.dirname(__FILE__) + '/../../../test/test_helper')


# The gem minitest-reporters gives color to the command-line
require "minitest/reporters"
Minitest::Reporters.use!
#require "minitest/rails/capybara"
require "mocha/mini_test"

# Needed in order to include the plugin fixtures defined in the plugin tests.
class ProjectType::TestCase
  
  def self.create_fixtures(fixtures_directory, table_names, class_names ={})
    if ActiveRecord::VERSION::MAJOR >= 4
      ActiveRecord::FixtureSet.create_fixtures(fixtures_directory, table_names, class_names ={})
    else
      ActiveRecord::Fixtures.create_fixtures(fixtures_directory, table_names, class_names ={})
    end
  end
  
end

#require File.expand_path(File.dirname(__FILE__) + '/../test/functional/projects_controller_patch_test')