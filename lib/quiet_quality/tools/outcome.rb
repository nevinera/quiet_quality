module QuietQuality
  module Tools
    class Outcome
      attr_reader :output, :logging, :tool

      def initialize(tool:, output:, logging: nil, failure: false)
        @tool = tool
        @output = output
        @logging = logging
        @failure = failure
      end

      def failure?
        @failure
      end

      def success?
        !failure?
      end

      def ==(other)
        tool == other.tool && output == other.output && logging == other.logging && failure? == other.failure?
      end
    end
  end
end
