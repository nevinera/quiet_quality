module QuietQuality
  module Executors
    class Execcer
      include Logging

      def initialize(tool_options:, changed_files: nil)
        @tool_options = tool_options
        @changed_files = changed_files
      end

      def exec!
        if runner.exec_command
          Kernel.exec(*runner.exec_command)
        else
          info <<~LOG_MESSAGE
            This runner does not believe it needs to execute at all.
            This typically means that it was told to target changed-files, but no relevant
            files were changed.
          LOG_MESSAGE
          Kernel.exit(0)
        end
      end

      private

      attr_reader :tool_options, :changed_files

      def limit_targets?
        tool_options.limit_targets?
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
        command_string = r.exec_command ? "`#{r.exec_command.join(" ")}`" : "(skipped)"
        info("Runner #{r.tool_name} exec_command: #{command_string}")
        debug("Full exec_command for #{r.tool_name}", data: r.exec_command)
      end
    end
  end
end
