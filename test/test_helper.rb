# frozen_string_literal: true

#
# Redmine plugin for xmera called Project Types Plugin.
#
# Copyright (C) 2017 - 2022 Liane Hampe <liaham@xmera.de>, xmera.
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
require File.expand_path('../../../test/test_helper', __dir__)
require_relative 'load_fixtures'
require_relative 'authenticate_user'
require_relative 'project_type_creator'

# The gem minitest-reporters gives color to the command-line
# require 'minitest/reporters'
# Minitest::Reporters.use!
# require "minitest/rails/capybara"
require 'minitest/unit'
require 'mocha/minitest'

module ProjectTypes
  class IntegrationTest < Redmine::IntegrationTest
    extend ProjectTypes::LoadFixtures
    include ProjectTypes::ProjectTypeCreator
    include Redmine::I18n
  end

  class UnitTest < ActiveSupport::TestCase
    include Redmine::I18n
    extend ProjectTypes::LoadFixtures
    include ProjectTypes::ProjectTypeCreator
  end
end
