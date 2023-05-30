module QuietQuality
  module Tools
    module Rubocop
      class Runner < RelevantRunner
        def tool_name
          :rubocop
        end

        def no_files_output
          '{"files": [], "summary": {"offense_count": 0}}'
        end

        def base_command
          ["rubocop", "-f", "json"]
        end

        def relevant_path?(path)
          path.end_with?(".rb")
        end
      end
    end
  end
end
