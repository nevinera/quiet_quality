module QuietQuality
  module Tools
    module HamlLint
      class Parser
        def initialize(text)
          @text = text
        end

        def messages
          return @_messages if defined?(@_messages)
          messages = content
            .fetch(:files)
            .map { |f| messages_for_file(f) }
            .flatten
          @_messages = Messages.new(messages)
        end

        private

        attr_reader :text

        def content
          @_content ||= JSON.parse(text, symbolize_names: true)
        end

        def messages_for_file(file_details)
          path = file_details.fetch(:path)
          file_details.fetch(:offenses).map do |offense|
            message_for_offense(path, offense)
          end
        end

        def message_for_offense(path, offense)
          Message.new(
            path: path,
            body: offense.fetch(:message),
            start_line: offense.dig(:location, :line),
            level: offense.fetch(:severity, nil),
            rule: offense.fetch(:linter_name, nil),
            tool_name: TOOL_NAME
          )
        end
      end
    end
  end
end
