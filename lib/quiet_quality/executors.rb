module QuietQuality
  module Executors
    Error = Class.new(::QuietQuality::Error)
  end
end

glob = File.expand_path("../executors/*.rb", __FILE__)
Dir.glob(glob).sort.each { |f| require f }

module QuietQuality
  module Executors
    AVAILABLE = {
      serial: SerialExecutor
    }
  end
end
