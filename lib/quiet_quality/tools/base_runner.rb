module QuietQuality
  module Tools
    class BaseRunner
      include Logging

      # In general, we don't want to supply a huge number of arguments to a command-line tool.
      MAX_FILES = 100

      def initialize(changed_files: nil, file_filter: nil, command_override: nil, exec_override: nil)
        @changed_files = changed_files
        @file_filter = file_filter
        @command_override = command_override
        @exec_override = exec_override
      end

      def invoke!
        @_outcome ||= performed_outcome
      end

      def tool_name
        fail(NoMethodError, "BaseRunner subclass must implement `tool_name`")
      end

      def command
        fail(NoMethodError, "BaseRunner subclass must implement `command`")
      end

      def exec_command
        fail(NoMethodError, "BaseRunner subclass must implement `exec_command`")
      end

      def success_status?(stat)
        stat.success?
      end

      # distinct from _error_ status - this is asking "does this status represent failures-found?"
      def failure_status?(stat)
        stat.exitstatus == 1
      end

      private

      attr_reader :changed_files, :file_filter, :command_override, :exec_override

      def performed_outcome
        out, err, stat = Open3.capture3(*command)
        log_performance(err, stat)

        if success_status?(stat)
          Outcome.new(tool: tool_name, output: out, logging: err, exit_status: stat.exitstatus)
        elsif failure_status?(stat)
          Outcome.new(tool: tool_name, output: out, logging: err, failure: true, exit_status: stat.exitstatus)
        else
          fail(ExecutionError, "Execution of #{tool_name} failed with #{stat.exitstatus}")
        end
      end

      def log_performance(err, stat)
        info("Runner #{tool_name} exited with #{stat.exitstatus}")
        debug("Runner logs from #{tool_name}:", data: err&.split("\n"))
      end
    end
  end
end
