module QuietQuality
  module Tools
    module Brakeman
      class Runner < BaseRunner
        def tool_name
          TOOL_NAME
        end

        def command
          ["brakeman", "-f", "json"]
        end

        def exec_command
          ["brakeman"]
        end

        # These are specified in constants at the top of brakeman.rb:
        #   https://github.com/presidentbeef/brakeman/blob/main/lib/brakeman.rb#L6-L25
        def failure_status?(stat)
          [3, 4, 5, 6, 7, 8].include?(stat.exitstatus)
        end
      end
    end
  end
end
