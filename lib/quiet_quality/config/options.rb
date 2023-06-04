module QuietQuality
  module Config
    class Options
      def initialize
        @annotator = nil
        @executor = Executors::ConcurrentExecutor
        @tools = nil
        @comparison_branch = nil
        @logging = Logging.new
      end

      attr_accessor :tools, :comparison_branch, :annotator, :executor
      attr_reader :logging

      def logging=(level)
        @logging.level = level
      end

      def colorize=(value)
        @logging.colorize = value
      end
    end
  end
end
