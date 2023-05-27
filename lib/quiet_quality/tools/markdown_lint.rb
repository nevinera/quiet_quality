module QuietQuality
  module Tools
    module MarkdownLint
      ExecutionError = Class.new(Tools::Error)
      ParsingError = Class.new(Tools::Error)
    end
  end
end

glob = File.expand_path("../markdown_lint/*.rb", __FILE__)
Dir.glob(glob).sort.each { |f| require f }
