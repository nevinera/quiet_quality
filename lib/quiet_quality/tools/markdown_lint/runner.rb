module QuietQuality
  module Tools
    module MarkdownLint
      class Runner
        MAX_FILES = 100
        NO_FILES_OUTPUT = "[]"
        FAILURE_STATUS = 1

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
            .select { |path| path.end_with?(".md") }
            .select { |path| file_filter.nil? || file_filter.match?(path) }
        end

        def target_files
          return ["."] if changed_files.nil?
          return ["."] if relevant_files.length > MAX_FILES
          return ["."] if relevant_files.empty?
          relevant_files
        end

        def command
          return nil if skip_execution?
          ["mdl", "--json"] + target_files.sort
        end

        def skipped_outcome
          Outcome.new(tool: :markdown_lint, output: NO_FILES_OUTPUT)
        end

        def performed_outcome
          out, err, stat = Open3.capture3(*command)
          if stat.success?
            Outcome.new(tool: :markdown_lint, output: out, logging: err)
          elsif stat.exitstatus == FAILURE_STATUS
            Outcome.new(tool: :markdown_lint, output: out, logging: err, failure: true)
          else
            fail(ExecutionError, "Execution of mdl failed with #{stat.exitstatus}")
          end
        end
      end
    end
  end
end
