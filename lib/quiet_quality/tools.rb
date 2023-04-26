module QuietQuality
  module Tools
    Error = Class.new(::QuietQuality::Error)
  end
end

glob = File.expand_path("../tools/*.rb", __FILE__)
Dir.glob(glob).sort.each { |f| require f }
