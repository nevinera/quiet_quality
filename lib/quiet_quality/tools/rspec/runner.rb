module QuietQuality
  module Tools
    module Rspec
      class Runner
        MAX_FILES = 100
        NO_FILES_OUTPUT = '{"examples": [], "summary": {"failure_count": 0}}'

        def initialize(changed_files: nil)
          @changed_files = changed_files
        end

        def invoke!
          @_outcome ||= skip_execution? ? skipped_outcome : performed_outcome
        end

        private

        attr_reader :changed_files, :error_stream

        def skip_execution?
          changed_files && relevant_files.empty?
        end

        def relevant_files
          return nil if changed_files.nil?
          changed_files.paths.select { |path| path.end_with?("_spec.rb") }
        end

        def target_files
          return [] if changed_files.nil?
          return [] if relevant_files.length > MAX_FILES
          relevant_files
        end

        def command
          return nil if skip_execution?
          ["rspec", "-f", "json"] + target_files.sort
        end

        def skipped_outcome
          Outcome.new(tool: :rspec, output: NO_FILES_OUTPUT)
        end

        def performed_outcome
          out, err, stat = Open3.capture3(*command)
          if stat.success?
            Outcome.new(tool: :rspec, output: out, logging: err)
          elsif stat.exitstatus == 1
            Outcome.new(tool: :rspec, output: out, logging: err, failure: true)
          else
            fail(ExecutionError, "Execution of rspec failed with #{stat.exitstatus}")
          end
        end
      end
    end
  end
end
