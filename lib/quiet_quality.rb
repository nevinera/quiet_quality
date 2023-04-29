require "git"
require "json"
require "yaml"

# 'set' doesn't need requiring after ruby 3.2, but it won't hurt anything.
# And we're compatible back to 2.6
require "set" # rubocop:disable Lint/RedundantRequireStatement

module QuietQuality
  Error = Class.new(StandardError)
end

glob = File.expand_path("../quiet_quality/*.rb", __FILE__)
Dir.glob(glob).sort.each { |f| require f }
