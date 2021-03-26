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
  ##
  # Redmine cannot load plugin fixtures by default.
  # This module loads first plugin fixtures and then Redmine fixtures
  # if the listed file does not exist in the plugin fixture directory.
  #
  module LoadFixtures
    def fixtures(*fixture_set_names)
      dir = File.join(File.dirname(__FILE__), '/fixtures')
      redmine_fixture_set_names = []
      fixture_set_names.each do |file|
        redmine_fixture_set_names << file unless create_fixtures(dir, file)
      end
      super(fixture_set_names) if redmine_fixture_set_names.any?
    end

    private

    def create_fixtures(dir, file)
      return unless File.exist?("#{dir}/#{file}.yml")

      ActiveRecord::FixtureSet.create_fixtures(dir, file)
    end
  end
end
