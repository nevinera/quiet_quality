module QuietQuality
  module Tools
    module HamlLint
      class Runner
        MAX_FILES = 100
        NO_FILES_OUTPUT = %({"files": []})

        # haml-lint uses the `sysexits` gem, and exits with Sysexits::EX_DATAERR for the
        # failures case here in lib/haml_lint/cli.rb. That's mapped to status 65 - other
        # statuses have other failure meanings, which we don't want to interpret as "problems
        # encountered"
        FAILURE_STATUS = 65

        def initialize(changed_files: nil, file_filter: nil)
          @changed_files = changed_files
          @file_filter = file_filter
        end

        def invoke!
          @_outcome ||= skip_execution? ? skipped_outcome : performed_outcome
        end

        private

        attr_reader :changed_files, :file_filter

        def skip_execution?
          changed_files && relevant_files.empty?
        end

        def relevant_files
          return nil if changed_files.nil?
          changed_files.paths
            .select { |path| path.end_with?(".haml") }
            .select { |path| file_filter.nil? || file_filter.match?(path) }
        end

        def target_files
          return [] if changed_files.nil?
          return [] if relevant_files.length > MAX_FILES
          relevant_files
        end

        def command
          return nil if skip_execution?
          ["haml-lint", "--reporter", "json"] + target_files.sort
        end

        def skipped_outcome
          Outcome.new(tool: :haml_lint, output: NO_FILES_OUTPUT)
        end

        def performed_outcome
          out, err, stat = Open3.capture3(*command)
          if stat.success?
            Outcome.new(tool: :haml_lint, output: out, logging: err)
          elsif stat.exitstatus == FAILURE_STATUS
            Outcome.new(tool: :haml_lint, output: out, logging: err, failure: true)
          else
            fail(ExecutionError, "Execution of haml-lint failed with #{stat.exitstatus}")
          end
        end
      end
    end
  end
end
