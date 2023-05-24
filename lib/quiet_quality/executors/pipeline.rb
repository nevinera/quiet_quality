module QuietQuality
  module Executors
    class Pipeline
      def initialize(tool_options:, changed_files: nil)
        @tool_options = tool_options
        @changed_files = changed_files
      end

      def tool_name
        tool_options.tool_name
      end

      def outcome
        @_outcome ||= runner.invoke!
      end

      def failure?
        messages.any?
      end

      def messages
        return @_messages if defined?(@_messages)
        @_messages = parser.messages
        @_messages = relevance_filter.filter(@_messages) if filter_messages? && changed_files
        @_messages.each { |m| locator.update!(m) } if changed_files
        @_messages
      end

      private

      attr_reader :changed_files, :tool_options

      def limit_targets?
        tool_options.limit_targets?
      end

      def filter_messages?
        tool_options.filter_messages?
      end

      def runner
        @_runner ||= tool_options.runner_class
          .new(changed_files: limit_targets? ? changed_files : nil)
      end

      def parser
        @_parser ||= tool_options.parser_class.new(outcome.output)
      end

      def relevance_filter
        @_relevance_filter ||= MessageFilter.new(changed_files: changed_files)
      end

      def locator
        @_locator ||= AnnotationLocator.new(changed_files: changed_files)
      end
    end
  end
end
