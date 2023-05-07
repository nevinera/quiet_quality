module QuietQuality
  module Tools
    module Rubocop
      ExecutionError = Class.new(Tools::Error)
      ParsingError = Class.new(Tools::Error)
    end
  end
end

glob = File.expand_path("../rubocop/*.rb", __FILE__)
Dir.glob(glob).sort.each { |f| require f }
