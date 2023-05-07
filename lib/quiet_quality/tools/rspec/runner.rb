module QuietQuality
  module Tools
    module Rspec
      class Runner
        MAX_FILES = 100
        NO_FILES_OUTPUT = '{"examples": [], "summary": {"failure_count": 0}}'

        def initialize(changed_files: nil, error_stream: $stderr)
          @changed_files = changed_files
          @error_stream = error_stream
        end

        def invoke!
          return NO_FILES_OUTPUT if skip_execution?
          out, err, stat = Open3.capture3(*command)
          error_stream.write(err)
          fail(ExecutionError, "Execution of rspec failed with #{stat.exitstatus}") unless stat.success?
          out
        end

        private

        attr_reader :changed_files, :error_stream

        def skip_execution?
          changed_files && relevant_files.empty?
        end

        def relevant_files
          return nil if changed_files.nil?
          changed_files.select { |path| path.end_with?("_spec.rb") }
        end

        def target_files
          return [] if changed_files.nil?
          return [] if relevant_files.length > MAX_FILES
          relevant_files
        end

        def command
          return nil if skip_execution?
          ["rspec", "--failure-exit-code", "0", "-f", "json"] + target_files.sort
        end
      end
    end
  end
end
