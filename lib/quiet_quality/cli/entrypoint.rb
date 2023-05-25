module QuietQuality
  module Cli
    class Entrypoint
      def initialize(argv:, output_stream: $stdout, error_stream: $stderr)
        @argv = argv
        @output_stream = output_stream
        @error_stream = error_stream
      end

      def execute
        if helping?
          log_help_text
        elsif printing_version?
          log_version_text
        else
          executed
          log_outcomes
          log_messages
          annotate_messages
        end

        self
      end

      def successful?
        helping? || printing_version? || !executed.any_failure?
      end

      private

      attr_reader :argv, :output_stream, :error_stream

      def arg_parser
        @_arg_parser ||= ArgParser.new(argv.dup)
      end

      def parsed_options
        @_parsed_options ||= arg_parser.parsed_options
      end

      def helping?
        parsed_options.helping?
      end

      def printing_version?
        parsed_options.printing_version?
      end

      def log_help_text
        error_stream.puts(arg_parser.help_text)
      end

      def log_version_text
        error_stream.puts(QuietQuality::VERSION)
      end

      def options
        return @_options if defined?(@_options)
        builder = Config::Builder.new(parsed_cli_options: parsed_options)
        @_options = builder.options
      end

      def changed_files
        return @_changed_files if defined?(@_changed_files)
        @_changed_files = VersionControlSystems::Git.new.changed_files(
          base: options.comparison_branch,
          sha: "HEAD",
          include_uncommitted: true,
          include_untracked: true
        )
      end

      def executor
        @_executor ||= options.executor.new(tools: options.tools, changed_files: changed_files)
      end

      def executed
        return @_executed if defined?(@_executed)
        executor.execute!
        @_executed = executor
      end

      def log_outcomes
        executed.outcomes.each do |outcome|
          result = outcome.success? ? "Passed" : "Failed"
          error_stream.puts "--- #{result}: #{outcome.tool}"
        end
      end

      def log_message(msg)
        line_range =
          if msg.start_line == msg.stop_line
            msg.start_line.to_s
          else
            "#{msg.start_line}-#{msg.stop_line}"
          end
        rule_string = msg.rule ? "  [#{msg.rule}]" : ""
        truncated_body = msg.body.gsub(/ *\n */, "\\n").slice(0, 120)
        error_stream.puts "  #{msg.path}:#{line_range}#{rule_string}  #{truncated_body}"
      end

      def log_messages
        return unless executed.messages.any?
        error_stream.puts "\n\n#{executed.messages.count} messages:"
        executed.messages.each { |msg| log_message(msg) }
      end

      def annotate_messages
        return unless options.annotator
        annotator = options.annotator.new(output_stream: output_stream)
        annotator.annotate!(executed.messages)
      end
    end
  end
end
