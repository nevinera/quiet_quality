module QuietQuality
  module Tools
    module MarkdownLint
      TOOL_NAME = :markdown_lint
    end
  end
end

glob = File.expand_path("../markdown_lint/*.rb", __FILE__)
Dir.glob(glob).sort.each { |f| require f }
