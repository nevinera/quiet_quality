module QuietQuality
  module Config
    class Options
      def initialize
        @annotator = nil
        @executor = Executors::ConcurrentExecutor
        @tools = nil
        @comparison_branch = nil
      end

      attr_accessor :tools, :comparison_branch, :annotator, :executor
    end
  end
end
