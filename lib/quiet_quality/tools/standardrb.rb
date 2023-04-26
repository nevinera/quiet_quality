module QuietQuality
  module Tools
    module Standardrb
      ExecutionError = Class.new(::QuietQuality::Error)
    end
  end
end

glob = File.expand_path("../standardrb/*.rb", __FILE__)
Dir.glob(glob).sort.each { |f| require f }
