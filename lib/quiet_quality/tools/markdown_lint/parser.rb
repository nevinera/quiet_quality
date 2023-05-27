module QuietQuality
  module Tools
    module MarkdownLint
      class Parser
        def initialize(text)
          @text = text
        end

        def messages
          return @_messages if defined?(@_messages)
          messages = content.map { |entry| message_for_entry(entry) }
          @_messages = Messages.new(messages)
        end

        private

        attr_reader :text

        def content
          @_content ||= JSON.parse(text, symbolize_names: true)
        end

        def message_for_entry(entry)
          Message.new(
            path: entry.fetch(:filename),
            start_line: entry.fetch(:line),
            rule: entry.fetch(:description),
            body: entry.fetch(:docs)
          )
        end
      end
    end
  end
end
