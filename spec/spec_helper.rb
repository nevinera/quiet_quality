require "rspec"
require "pry"

require File.expand_path("../../lib/quiet_quality", __FILE__)

gem_root = File.expand_path("../..", __FILE__)
FIXTURES_DIRECTORY = File.join(gem_root, "spec", "fixtures")

def fixture_path(*parts)
  File.join(FIXTURES_DIRECTORY, *parts)
end

def fixture_content(*parts)
  File.read(fixture_path(*parts))
end

def fixture_json(*parts)
  JSON.parse(fixture_content(*parts))
end

RSpec.configure do |config|
  config.raise_errors_for_deprecations!
  config.mock_with :rspec
  config.order = "random"
  config.tty = true
end
