module QuietQuality
  module Annotators
  end
end

glob = File.expand_path("../annotators/*.rb", __FILE__)
Dir.glob(glob).sort.each { |f| require(f) }
