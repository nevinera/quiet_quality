module QuietQuality
  module Tools
    module Rspec
      TOOL_NAME = :rspec

      Error = Class.new(Tools::Error)
    end
  end
end

glob = File.expand_path("../rspec/*.rb", __FILE__)
Dir.glob(glob).sort.each { |f| require f }
