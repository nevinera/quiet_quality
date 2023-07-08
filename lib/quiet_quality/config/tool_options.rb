module QuietQuality
  module Config
    class ToolOptions
      def initialize(tool, limit_targets: true, filter_messages: true, file_filter: nil)
        @tool_name = tool.to_sym
        @limit_targets = limit_targets
        @filter_messages = filter_messages
        @file_filter = file_filter
      end

      attr_accessor :file_filter
      attr_reader :tool_name
      attr_writer :limit_targets, :filter_messages

      def limit_targets?
        @limit_targets
      end

      def filter_messages?
        @filter_messages
      end

      def tool_namespace
        Tools::AVAILABLE.fetch(tool_name)
      end

      def runner_class
        tool_namespace::Runner
      end

      def parser_class
        tool_namespace::Parser
      end

      def to_h
        {
          tool_name: tool_name,
          limit_targets: limit_targets?,
          filter_messages: filter_messages?,
          file_filter: file_filter&.regex&.to_s,
          excludes: file_filter&.excludes&.map(&:to_s)
        }
      end
    end
  end
end
