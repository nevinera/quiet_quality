module QuietQuality
  module Cli
    class ToolOptions
      def initialize(tool, limit_targets: true, filter_messages: true)
        @tool_name = tool.to_sym
        @limit_targets = limit_targets
        @filter_messages = filter_messages
      end

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
    end
  end
end
