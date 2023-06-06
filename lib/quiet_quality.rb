require "git"
require "git_diff_parser"
require "json"
require "yaml"
require "pathname"

# 'set' doesn't need requiring after ruby 3.2, but it won't hurt anything.
# And we're compatible back to 2.6
require "set" # rubocop:disable Lint/RedundantRequireStatement

module QuietQuality
  Error = Class.new(StandardError)

  def self.logger
    @_logger ||= QuietQuality::Logger.new
  end
end

require_relative "./quiet_quality/logger"
require_relative "./quiet_quality/logging"
glob = File.expand_path("../quiet_quality/*.rb", __FILE__)
Dir.glob(glob).sort.each { |f| require f }
