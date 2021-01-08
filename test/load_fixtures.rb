module RedmineProjectTypes 
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