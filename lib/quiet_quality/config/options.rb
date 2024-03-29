module QuietQuality
  module Config
    class Options
      LOGGING_LEVELS = [:quiet, :light, :normal].freeze

      def initialize
        @annotator = nil
        @executor = Executors::ConcurrentExecutor
        @tools = nil
        @exec_tool = nil
        @comparison_branch = nil
        @colorize = true
        @logging = :normal
        @message_format = nil
      end

      attr_accessor :tools, :comparison_branch, :annotator, :executor, :exec_tool, :message_format
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

      def to_h
        {
          annotator: annotator,
          executor: executor.name,
          exec_tool: exec_tool,
          comparison_branch: comparison_branch,
          colorize: colorize?,
          logging: logging,
          message_format: message_format,
          tools: tool_hashes_by_name
        }
      end

      private

      def tool_hashes_by_name
        return {} unless tools
        tools
          .map { |tool_option| [tool_option.tool_name, tool_option.to_h] }
          .to_h
      end
    end
  end
end
