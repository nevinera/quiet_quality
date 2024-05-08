require_relative "base_runner"

module QuietQuality
  module Tools
    class RelevantRunner < BaseRunner
      # In general, we don't want to supply a huge number of arguments to a command-line tool.
      # This will probably become configurable later.
      MAX_FILES = 100

      def invoke!
        @_outcome ||= skip_execution? ? skipped_outcome : performed_outcome
      end

      def command
        return nil if skip_execution?
        (command_override || base_command) + target_files.sort
      end

      def exec_command
        return nil if skip_execution?
        (exec_override || base_exec_command) + target_files.sort
      end

      def relevant_path?(path)
        fail(NoMethodError, "RelevantRunner subclass must implement `relevant_path?`")
      end

      def base_command
        fail(NoMethodError, "RelevantRunner subclass must implement either `command` or `base_command`")
      end

      def base_exec_command
        fail(NoMethodError, "RelevantRunner subclass must implement either `exec_command` or `base_exec_command`")
      end

      def no_files_output
        fail(NoMethodError, "RelevantRunner subclass must implement `no_files_output`")
      end

      private

      def skip_execution?
        changed_files && relevant_files.empty?
      end

      def relevant_files
        return nil if changed_files.nil?
        changed_files.paths
          .select { |path| relevant_path?(path) }
          .select { |path| file_filter.nil? || file_filter.match?(path) }
      end

      def target_files
        return [] if changed_files.nil?
        return [] if relevant_files.length > MAX_FILES
        relevant_files
      end

      def skipped_outcome
        info("Runner #{tool_name} was skipped")
        Outcome.new(tool: tool_name, output: no_files_output)
      end
    end
  end
end
