require_relative "rubocop"

module QuietQuality
  module Tools
    module Brakeman
      TOOL_NAME = :brakeman
    end
  end
end

glob = File.expand_path("../brakeman/*.rb", __FILE__)
Dir.glob(glob).sort.each { |f| require f }
