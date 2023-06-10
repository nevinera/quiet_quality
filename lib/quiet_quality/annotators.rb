module QuietQuality
  module Annotators
    Unrecognized = Class.new(Error)
  end
end

glob = File.expand_path("../annotators/*.rb", __FILE__)
Dir.glob(glob).sort.each { |f| require(f) }

module QuietQuality
  module Annotators
    ANNOTATOR_TYPES = {
      github_stdout: Annotators::GithubStdout
    }.freeze

    def self.annotate!(annotator:, messages:, limit: nil)
      limited_messages = limit ? messages.first(limit) : messages
      ANNOTATOR_TYPES.fetch(annotator.to_sym).new.annotate!(limited_messages)
    rescue KeyError
      fail Unrecognized, "Unrecognized annotator_type '#{annotator}'"
    end
  end
end
