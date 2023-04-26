require "rspec"
require "pry"

require File.expand_path("../../lib/quiet_quality", __FILE__)

RSpec.configure do |config|
  config.raise_errors_for_deprecations!
  config.mock_with :rspec
  config.order = "random"
  config.tty = true
end
