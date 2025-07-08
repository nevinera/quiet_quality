module QuietQuality
  module Tools
    module Rspec
      class Parser
        include Logging

        def initialize(outcome, tool_options:)
          @outcome = outcome
          @tool_options = tool_options
        end

        def messages
          return @_messages if defined?(@_messages)
          messages = failed_examples.map { |ex| message_for(ex) }
          messages << coverage_message unless tool_options.limit_targets?
          @_messages = Messages.new(messages.compact)
        end

        private

        attr_reader :outcome, :tool_options

        def text
          outcome.output
        end

        # Many people use simplecov with rspec, and its default formatter
        # writes text output into the stdout stream of rspec even when rspec is
        # asked for json output. I have an issue open here, and I'll get a pair
        # of PRs together if they indicate any willingness to accept such a
        # change: https://github.com/simplecov-ruby/simplecov/issues/1060
        #
        # The only stdout writes are visible on these lines:
        # https://github.com/simplecov-ruby/simplecov-html/blob/main/lib/simplecov-html.rb#L31
        # https://github.com/simplecov-ruby/simplecov-html/blob/main/lib/simplecov-html.rb#L80
        #
        # There are _hundreds_ of rspec plugins, and any of them could write to
        # stdout - we probably won't worry about any but the most common.
        def cleaned_text
          @_cleaned_text ||= text
            .sub(/}Coverage report generated.*/m, "}\n")
            .gsub(/^Encoding problems with file.*$/, "")
            .gsub(/}Encoding problems with file.*$/, "}")
        end

        def content
          @_content ||= JSON.parse(cleaned_text, symbolize_names: true)
        end

        def examples
          return @_examples if defined?(@_examples)
          raise_if_errors_outside_of_examples!
          @_examples = content.fetch(:examples)
        end

        def failed_examples
          @_failed_examples ||= examples.select { |ex| ex[:status] == "failed" }
        end

        def reduced_path(path)
          path.gsub(%r{^\./}, "")
        end

        def message_for(example)
          path = reduced_path(example.fetch(:file_path))
          body = example.dig(:exception, :message) || example.fetch(:description)
          line = example.fetch(:line_number)
          rule = example.dig(:exception, :class) || "Failed Example"
          Message.new(
            path: path,
            body: body,
            start_line: line,
            rule: rule,
            tool_name: TOOL_NAME
          )
        end

        def errors_count
          @_errors_count ||= content.dig(:summary, :errors_outside_of_examples_count) || 0
        end

        def error_messages
          @_error_messages ||= content.fetch(:messages, [])
        end

        def raise_if_errors_outside_of_examples!
          return if errors_count < 1
          warn "RSpec errors:"
          warn "-" * 80
          error_messages.each do |msg|
            warn msg
            warn "-" * 80
          end
          fail Rspec::Error, "Rspec encountered #{errors_count} errors outside of examples"
        end

        def net_coverage_message
          Message.new(
            path: "all",
            body: "Net coverage was insufficient",
            start_line: 0,
            rule: "Net Coverage",
            tool_name: TOOL_NAME
          )
        end

        def per_file_coverage_message
          Message.new(
            path: "all",
            body: "Per-file coverage was insufficient",
            start_line: 0,
            rule: "Per-File Coverage",
            tool_name: TOOL_NAME
          )
        end

        def coverage_message
          @_coverage_message ||=
            case outcome.exit_status
            when 2 then net_coverage_message
            when 3 then per_file_coverage_message
            else
              nil
            end
        end
      end
    end
  end
end
