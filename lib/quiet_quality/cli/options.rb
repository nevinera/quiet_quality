module QuietQuality
  module Cli
    class Options
      def initialize
        @annotator = nil
        @executor = Executors::ConcurrentExecutor
        @tools = nil
      end

      attr_reader :annotator, :executor
      attr_accessor :tools

      def annotator=(name)
        @annotator = Annotators::ANNOTATOR_TYPES.fetch(name.to_sym)
      rescue KeyError
        fail(UsageError, "Unrecognized annotator: #{name}")
      end

      def executor=(name)
        @executor = Executors::AVAILABLE.fetch(name.to_sym)
      rescue KeyError
        fail(UsageError, "Unrecognized executor: #{name}")
      end
    end
  end
end
