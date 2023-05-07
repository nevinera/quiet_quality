require_relative "./annotators"
require_relative "./tools"

module QuietQuality
  module Cli
    Error = Class.new(QuietQuality::Error)
    UsageError = Class.new(Error)
  end
end

glob = File.expand_path("../cli/*.rb", __FILE__)
Dir.glob(glob).sort.each { |f| require f }
