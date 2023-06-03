module QuietQuality
  module Tools
    module Rspec
      TOOL_NAME = :rspec
    end
  end
end

glob = File.expand_path("../rspec/*.rb", __FILE__)
Dir.glob(glob).sort.each { |f| require f }
