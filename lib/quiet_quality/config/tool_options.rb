module QuietQuality
  module Config
    class ToolOptions
      def initialize(tool, limit_targets: true, filter_messages: true, file_filter: nil)
        @tool_name = tool.to_sym
        @limit_targets = limit_targets
        @filter_messages = filter_messages
        @file_filter = file_filter
      end

      attr_reader :tool_name
      attr_writer :limit_targets, :filter_messages, :file_filter

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

      def file_filter
        return nil if @file_filter.nil?
        Regexp.new(@file_filter)
      end

      def to_h
        {
          tool_name: tool_name,
          limit_targets: limit_targets?,
          filter_messages: filter_messages?,
          file_filter: file_filter&.to_s
        }
      end
    end
  end
end
