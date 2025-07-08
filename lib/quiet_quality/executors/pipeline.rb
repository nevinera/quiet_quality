module QuietQuality
  module Executors
    class Pipeline
      include Logging

      def initialize(tool_options:, changed_files: nil)
        @tool_options = tool_options
        @changed_files = changed_files
      end

      def tool_name
        tool_options.tool_name
      end

      def outcome
        @_outcome ||= Tools::Outcome.new(
          tool: runner_outcome.tool,
          output: runner_outcome.output,
          logging: runner_outcome.logging,
          failure: messages.any?
        )
      end

      def failure?
        outcome.failure?
      end

      def messages
        return @_messages if defined?(@_messages)
        @_messages = relocated(filtered(parser.messages))
      end

      private

      attr_reader :changed_files, :tool_options

      def runner_outcome
        @_runner_outcome ||= runner.invoke!
      end

      def limit_targets?
        tool_options.limit_targets?
      end

      def filter_messages?
        tool_options.filter_messages?
      end

      def runner
        @_runner ||= tool_options.runner_class.new(
          changed_files: limit_targets? ? changed_files : nil,
          file_filter: tool_options.file_filter,
          command_override: tool_options.command,
          exec_override: tool_options.exec_command
        ).tap { |r| log_runner(r) }
      end

      def log_runner(r)
        command_string = r.command ? "`#{r.command.join(" ")}`" : "(skipped)"
        info("Runner #{r.tool_name} command: #{command_string}")
        debug("Full command for #{r.tool_name}", data: r.command)
      end

      def parser
        @_parser ||= tool_options.parser_class.new(runner_outcome.output, tool_options: tool_options)
      end

      def relevance_filter
        @_relevance_filter ||= MessageFilter.new(changed_files: changed_files)
      end

      def locator
        @_locator ||= AnnotationLocator.new(changed_files: changed_files)
      end

      def filtered(messages_object)
        return messages_object unless filter_messages? && changed_files

        original_count = messages_object.count
        relevance_filter.filter(messages_object).tap do |filtered|
          info("Messages for #{tool_name} filtered from #{original_count} to #{filtered.count}")
        end
      end

      def relocated(messages_object)
        if changed_files && !messages_object.empty?
          messages_object.each { |m| locator.update!(m) }
          info("Messages for #{tool_name} positioned into the diff for annotation purposes")
        end
        messages_object
      end
    end
  end
end
