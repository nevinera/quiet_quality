module QuietQuality
  module Tools
    module HamlLint
      class Runner < RelevantRunner
        def tool_name
          TOOL_NAME
        end

        def no_files_output
          %({"files": []})
        end

        def base_command
          ["haml-lint", "--reporter", "json"]
        end

        def relevant_path?(path)
          path.end_with?(".haml")
        end

        # haml-lint uses the `sysexits` gem, and exits with Sysexits::EX_DATAERR for the
        # failures case here in lib/haml_lint/cli.rb. That's mapped to status 65 - other
        # statuses have other failure meanings, which we don't want to interpret as "problems
        # encountered"
        def failure_status?(stat)
          stat.exitstatus == 65
        end
      end
    end
  end
end
