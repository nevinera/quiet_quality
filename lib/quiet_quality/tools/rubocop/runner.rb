module QuietQuality
  module Tools
    module Rubocop
      class Runner
        MAX_FILES = 100
        NO_FILES_OUTPUT = '{"files": [], "summary": {"offense_count": 0}}'

        def command_name
          "rubocop"
        end

        # Supplying changed_files: nil means "run against all files".
        def initialize(changed_files: nil, file_filter: nil)
          @changed_files = changed_files
          @file_filter = file_filter
        end

        def invoke!
          @_outcome ||= skip_execution? ? skipped_outcome : performed_outcome
        end

        private

        attr_reader :changed_files, :file_filter

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
          [command_name, "-f", "json"] + target_files.sort
        end

        def relevant_files
          return nil if changed_files.nil?
          changed_files.paths
            .select { |path| path.end_with?(".rb") }
            .select { |path| file_filter.nil? || file_filter.match?(path) }
        end

        def target_files
          return [] if changed_files.nil?
          return [] if relevant_files.length > MAX_FILES
          relevant_files
        end

        def skipped_outcome
          Outcome.new(tool: command_name.to_sym, output: NO_FILES_OUTPUT)
        end

        def performed_outcome
          out, err, stat = Open3.capture3(*command)
          if stat.success?
            Outcome.new(tool: command_name.to_sym, output: out, logging: err)
          elsif stat.exitstatus == 1
            Outcome.new(tool: command_name.to_sym, output: out, logging: err, failure: true)
          else
            fail(ExecutionError, "Execution of #{command_name} failed with #{stat.exitstatus}")
          end
        end
      end
    end
  end
end
