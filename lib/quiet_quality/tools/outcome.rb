module QuietQuality
  module Tools
    class Outcome
      attr_reader :output, :logging, :tool, :exit_status

      def initialize(tool:, output:, logging: nil, failure: false, exit_status: nil)
        @tool = tool
        @output = output
        @logging = logging
        @failure = failure
        @exit_status = exit_status
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
