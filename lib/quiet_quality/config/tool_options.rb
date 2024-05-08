module QuietQuality
  module Config
    class ToolOptions
      def initialize(tool, **options)
        @tool_name = tool.to_sym
        @limit_targets = options.fetch(:limit_targets, true)
        @filter_messages = options.fetch(:filter_messages, true)
        @file_filter = options.fetch(:file_filter, nil)
        @command = options.fetch(:command, nil)
        @exec_command = options.fetch(:exec_command, nil)
      end

      attr_accessor :file_filter, :command, :exec_command
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
          command: command,
          exec_command: exec_command,
          excludes: file_filter&.excludes&.map(&:to_s)
        }
      end
    end
  end
end
