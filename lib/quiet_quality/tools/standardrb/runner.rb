module QuietQuality
  module Tools
    module Standardrb
      class Runner < RelevantRunner
        def tool_name
          TOOL_NAME
        end

        def no_files_output
          '{"files": [], "summary": {"offense_count": 0}}'
        end

        def base_command
          ["standardrb", "-f", "json"]
        end

        def base_exec_command
          ["standardrb"]
        end

        def relevant_path?(path)
          path.end_with?(".rb")
        end
      end
    end
  end
end
