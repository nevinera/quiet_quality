module QuietQuality
  module Cli
    class Options
      def initialize
        @annotator = nil
        @tools = nil
      end

      attr_reader :annotator
      attr_accessor :tools

      def annotator=(name)
        @annotator = Annotators::ANNOTATOR_TYPES.fetch(name.to_sym)
      rescue KeyError
        fail(UsageError, "Unrecognized annotator: #{name}")
      end
    end
  end
end
