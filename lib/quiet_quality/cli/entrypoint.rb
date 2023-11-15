module QuietQuality
  module Cli
    class Entrypoint
      include Logging

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
        elsif no_tools?
          log_no_tools_text
        else
          log_options
          execute!
          log_results
          annotate_messages
        end

        self
      end

      def successful?
        return true if helping? || printing_version?
        return false if no_tools?
        !executed.any_failure?
      end

      private

      attr_reader :argv, :output_stream, :error_stream

      def presenter
        @_presenter ||= Presenter.new(
          stream: error_stream,
          options: options,
          outcomes: executor.outcomes,
          messages: executor.messages
        )
      end

      def log_options
        debug("Complete Options object:", data: options.to_h)
      end

      def log_results
        presenter.log_results
      end

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

      def no_tools?
        options.tools.empty?
      end

      def log_help_text
        error_stream.puts(arg_parser.help_text)
      end

      def log_version_text
        error_stream.puts(QuietQuality::VERSION)
      end

      def log_no_tools_text
        error_stream.puts(<<~TEXT)
          You must specify one or more tools to run, either on the command-line or in the
          default_tools key in a configuration file.
        TEXT
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

      def exec_tool_options
        @_exec_tool_options ||= options.tools
          .detect { |topts| topts.tool_name == options.exec_tool.to_sym }
      end

      def execcer
        @_execcer ||= QuietQuality::Executors::Execcer.new(
          tool_options: exec_tool_options,
          changed_files: changed_files
        )
      end

      def execute!
        if options.exec_tool
          execcer.exec!
        else
          executed
        end
      end

      def annotate_messages
        return unless options.annotator
        info("Annotating with #{options.annotator}")
        annotator = options.annotator.new(output_stream: output_stream)
        annotator.annotate!(executed.messages)
      end
    end
  end
end
