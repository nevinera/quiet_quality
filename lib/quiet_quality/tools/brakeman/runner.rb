module QuietQuality
  module Tools
    module Brakeman
      class Runner
        # These are specified in constants at the top of brakeman.rb:
        #   https://github.com/presidentbeef/brakeman/blob/main/lib/brakeman.rb#L6-L25
        KNOWN_EXIT_STATUSES = [3, 4, 5, 6, 7, 8].to_set

        def initialize(changed_files: nil)
          @changed_files = changed_files
        end

        def invoke!
          @_outcome ||= performed_outcome
        end

        private

        def command
          ["brakeman", "-f", "json"]
        end

        def performed_outcome
          out, err, stat = Open3.capture3(*command)
          if stat.success?
            Outcome.new(tool: :brakeman, output: out, logging: err)
          elsif KNOWN_EXIT_STATUSES.include?(stat.exitstatus)
            Outcome.new(tool: :brakeman, output: out, logging: err, failure: true)
          else
            fail(ExecutionError, "Execution of brakeman failed with #{stat.exitstatus}")
          end
        end
      end
    end
  end
end
