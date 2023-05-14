module QuietQuality
  module Config
    Error = Class.new(QuietQuality::Error)
  end
end

glob = File.expand_path("../config/*.rb", __FILE__)
Dir.glob(glob).sort.each { |f| require f }
