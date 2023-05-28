module QuietQuality
  module Tools
    module Rspec
      class Runner < RelevantRunner
        def tool_name
          :rspec
        end

        def no_files_output
          '{"examples": [], "summary": {"failure_count": 0}}'
        end

        def base_command
          ["rspec", "-f", "json"]
        end

        def relevant_path?(path)
          path.end_with?("_spec.rb")
        end
      end
    end
  end
end
