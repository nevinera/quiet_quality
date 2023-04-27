module QuietQuality
  module Tools
    module Standardrb
      class Runner
        MAX_FILES = 100
        NO_FILES_OUTPUT = '{"files": [], "summary": {"offense_count": 0}}'

        # Supplying changed_files: nil means "run against all files".
        # error_stream is really just injectable for unit-testing purposes.
        def initialize(changed_files: nil, error_stream: $stderr)
          @changed_files = changed_files
          @error_stream = error_stream
        end

        def invoke!
          return NO_FILES_OUTPUT if skip_execution?
          out, err, stat = Open3.capture3(*command)
          error_stream.write(err)
          fail(ExecutionError, "Execution of standardrb failed with #{stat.exitstatus}") unless stat.success?
          out
        end

        private

        attr_reader :changed_files, :error_stream

        # If we were told that _no files changed_ (which is distinct from not being told that
        # any files changed - a [] instead of a nil), then we shouldn't run rubocop at all.
        def skip_execution?
          changed_files && relevant_files.empty?
        end

        # Note: if target_files goes over MAX_FILES, it's _empty_ instead - that means that
        # we run against the full repository instead of the specific files (rubocop's behavior
        # when no target files are specified)
        def command
          return nil if skip_execution?
          ["standardrb", "-f", "json", "--fail-level", "fatal"] + target_files.sort
        end

        def relevant_files
          return nil if changed_files.nil?
          changed_files.select { |path| path.end_with?(".rb") }
        end

        def target_files
          return [] if changed_files.nil?
          return [] if relevant_files.length > MAX_FILES
          relevant_files
        end
      end
    end
  end
end
