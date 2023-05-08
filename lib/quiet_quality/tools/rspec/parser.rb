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

        def content
          @_content ||= JSON.parse(text, symbolize_names: true)
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
          Message.new(path: path, body: body, start_line: line, rule: rule)
        end
      end
    end
  end
end
