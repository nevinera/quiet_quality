require "open3"

module QuietQuality
  module Tools
    Error = Class.new(::QuietQuality::Error)
    ExecutionError = Class.new(Error)
    ParsingError = Class.new(Error)
  end
end

require_relative "tools/base_runner"
require_relative "tools/relevant_runner"

glob = File.expand_path("../tools/*.rb", __FILE__)
Dir.glob(glob).sort.each { |f| require f }

# reopen the class after the tools have been loaded, so we can list them for reference elsewhere.
module QuietQuality
  module Tools
    AVAILABLE = {
      brakeman: Brakeman,
      haml_lint: HamlLint,
      markdown_lint: MarkdownLint,
      rspec: Rspec,
      rubocop: Rubocop,
      standardrb: Standardrb
    }
  end
end
