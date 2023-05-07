module QuietQuality
  module Tools
    class Outcome
      attr_reader :output, :logging

      def initialize(output:, logging: nil, failure: false)
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
        output == other.output && logging == other.logging && failure? == other.failure?
      end
    end
  end
end
