module QuietQuality
  module Tools
    module Brakeman
      class Runner
        # These are specified in constants at the top of brakeman.rb:
        #   https://github.com/presidentbeef/brakeman/blob/main/lib/brakeman.rb#L6-L25
        KNOWN_EXIT_STATUSES = [3, 4, 5, 6, 7, 8].to_set

        # brakeman does not support being run against a portion of the project, so neither
        # changed_files nor file_filter is actually used. But they are accepted here because
        # that is what Runner initializers are required to accept.
        def initialize(changed_files: nil, file_filter: nil)
          @changed_files = changed_files
          @file_filter = file_filter
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
