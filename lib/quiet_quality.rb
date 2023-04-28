require "git"
require "json"
require "yaml"

module QuietQuality
  Error = Class.new(StandardError)
end

glob = File.expand_path("../quiet_quality/*.rb", __FILE__)
Dir.glob(glob).sort.each { |f| require f }
