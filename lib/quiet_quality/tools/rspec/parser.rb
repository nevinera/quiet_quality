module QuietQuality
  module Tools
    module Rspec
      class Parser
        def initialize(text)
          @text = text
        end

        def messages
          return @_messages if defined?(@_messages)
          messages = failed_examples.map { |ex| message_for(ex) }
          @_messages = Messages.new(messages)
        end

        private

        attr_reader :text

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
            .gsub(/Coverage report generated.*covered.$/, "")
            .gsub(/Encoding problems with file.*$/, "")
        end

        def content
          @_content ||= JSON.parse(cleaned_text, symbolize_names: true)
        end

        def examples
          @_examples ||= content.fetch(:examples)
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
      end
    end
  end
end
