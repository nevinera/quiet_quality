module QuietQuality
  module Tools
    class BaseRunner
      # In general, we don't want to supply a huge number of arguments to a command-line tool.
      MAX_FILES = 100

      def initialize(changed_files: nil, file_filter: nil)
        @changed_files = changed_files
        @file_filter = file_filter
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

      def success_status?(stat)
        stat.success?
      end

      # distinct from _error_ status - this is asking "does this status represent failures-found?"
      def failure_status?(stat)
        stat.exitstatus == 1
      end

      private

      attr_reader :changed_files, :file_filter

      def performed_outcome
        out, err, stat = Open3.capture3(*command)
        if success_status?(stat)
          Outcome.new(tool: tool_name, output: out, logging: err)
        elsif failure_status?(stat)
          Outcome.new(tool: tool_name, output: out, logging: err, failure: true)
        else
          fail(ExecutionError, "Execution of #{tool_name} failed with #{stat.exitstatus}")
        end
      end
    end
  end
end
