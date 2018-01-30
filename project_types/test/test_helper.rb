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