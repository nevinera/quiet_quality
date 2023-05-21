require "open3"

module QuietQuality
  module Tools
    Error = Class.new(::QuietQuality::Error)
  end
end

glob = File.expand_path("../tools/*.rb", __FILE__)
Dir.glob(glob).sort.each { |f| require f }

# reopen the class after the tools have been loaded, so we can list them for reference elsewhere.
module QuietQuality
  module Tools
    AVAILABLE = {
      brakeman: Brakeman,
      haml_lint: HamlLint,
      rspec: Rspec,
      rubocop: Rubocop,
      standardrb: Standardrb
    }
  end
end
