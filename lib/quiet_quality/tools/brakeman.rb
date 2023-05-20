require_relative "./rubocop"

module QuietQuality
  module Tools
    module Brakeman
      ExecutionError = Class.new(Tools::Error)
      ParsingError = Class.new(Tools::Error)
    end
  end
end

glob = File.expand_path("../brakeman/*.rb", __FILE__)
Dir.glob(glob).sort.each { |f| require f }