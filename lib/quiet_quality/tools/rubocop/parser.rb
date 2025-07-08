module QuietQuality
  module Tools
    module Rubocop
      class Parser
        def initialize(text, tool_options:)
          @text = text
          @tool_options = tool_options
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

        attr_reader :text, :tool_options

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
            start_line: offense.dig(:location, :start_line),
            stop_line: offense.dig(:location, :last_line),
            level: offense.fetch(:severity, nil),
            rule: offense.fetch(:cop_name, nil),
            tool_name: tool_name
          )
        end

        def tool_name
          TOOL_NAME
        end
      end
    end
  end
end
