module QuietQuality
  module Tools
    module Rspec
      class Runner < RelevantRunner
        def tool_name
          TOOL_NAME
        end

        def no_files_output
          '{"examples": [], "summary": {"failure_count": 0}}'
        end

        def base_command
          ["rspec", "-f", "json"]
        end

        def base_exec_command
          ["rspec"]
        end

        def relevant_path?(path)
          path.end_with?("_spec.rb")
        end

        # When simplecov is set up, it exits with a 2 when there's a _coverage_ failure
        # (and no test failures).
        def success_status?(stat)
          return !!changed_files if [2, 3].include?(stat.exitstatus)
          super
        end

        def failure_status?(stat)
          return !changed_files if [2, 3].include?(stat.exitstatus)
          super
        end
      end
    end
  end
end
