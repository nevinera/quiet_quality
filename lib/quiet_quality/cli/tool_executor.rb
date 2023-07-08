module QuietQuality
  module Cli
    class ToolExecutor
      include Logging

      def initialize(argv:)
        @argv = argv
      end

      # returns [command, message] - the script will exec(*command) if present,
      # otherwise warn(message)
      def executable_command
        if helping?
          [nil, arg_parser.help_text]
        elsif printing_version?
          log_version_text
          [nil, QuietQuality::VERSION]
        else
          log_options
          [command, nil]
        end
      end

      private

      attr_reader :argv

      def log_options
        debug("Complete Options object:", data: options.to_h)
      end

      def arg_parser
        @_arg_parser ||= ExecArgParser.new(argv.dup)
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

      def tool_options
        @_tool_options = options.tools.first
      end

      def runner
        @_runner ||= tool_options.runner_class.new(
          changed_files: tool_options.limit_targets? ? changed_files : nil,
          file_filter: tool_options.file_filter
        ).tap { |r| log_runner(r) }
      end

      def log_runner(r)
        command_string = r.exec_command ? "`#{r.exec_command.join(" ")}`" : "(skipped)"
        info("Runner #{r.tool_name} command: #{command_string}")
        debug("Full command for #{r.tool_name}", data: r.exec_command)
      end

      def command
        return @_command if defined?(@_command)
        @_command = runner.exec_command
      end
    end
  end
end
