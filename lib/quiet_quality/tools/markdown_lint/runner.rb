module QuietQuality
  module Tools
    module MarkdownLint
      class Runner < RelevantRunner
        def tool_name
          TOOL_NAME
        end

        def no_files_output
          "[]"
        end

        def command
          return nil if skip_execution?
          if target_files.any?
            ["mdl", "--json"] + target_files.sort
          else
            ["mdl", "--json", "."]
          end
        end

        def relevant_path?(path)
          path.end_with?(".md")
        end
      end
    end
  end
end
