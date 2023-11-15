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

        def command(json: true)
          return nil if skip_execution?
          base_command = ["mdl"]
          base_command << "--json" if json
          if target_files.any?
            base_command + target_files.sort
          else
            base_command + ["."]
          end
        end

        def exec_command
          command(json: false)
        end

        def relevant_path?(path)
          path.end_with?(".md")
        end
      end
    end
  end
end
