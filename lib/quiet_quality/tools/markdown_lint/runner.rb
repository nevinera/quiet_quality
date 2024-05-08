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
          (command_override || ["mdl", "--json"]) + command_targets
        end

        def exec_command
          return nil if skip_execution?
          (exec_override || ["mdl"]) + command_targets
        end

        def relevant_path?(path)
          path.end_with?(".md")
        end

        private

        def command_targets
          if target_files.any?
            target_files.sort
          else
            ["."]
          end
        end
      end
    end
  end
end
