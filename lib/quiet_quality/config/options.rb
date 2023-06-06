module QuietQuality
  module Config
    class Options
      LOGGING_LEVELS = [:quiet, :light, :normal].freeze

      def initialize
        @annotator = nil
        @executor = Executors::ConcurrentExecutor
        @tools = nil
        @comparison_branch = nil
        @colorize = true
        @logging = :normal
      end

      attr_accessor :tools, :comparison_branch, :annotator, :executor
      attr_reader :logging
      attr_writer :colorize

      def logging=(level)
        fail(ArgumentError, "Unrecognized logging level '#{level}'") unless LOGGING_LEVELS.include?(level.to_sym)
        @logging = level.to_sym
      end

      def colorize?
        !!@colorize
      end

      def quiet?
        logging == :quiet
      end

      def light?
        logging == :light
      end
    end
  end
end
