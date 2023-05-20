module QuietQuality
  module Tools
    module Brakeman
      class Parser
        def initialize(text)
          @text = text
        end

        def messages
          return @_messages if defined?(@_messages)
          check_errors!
          messages = warnings.map { |w| message_for(w) }
          @_messages = Messages.new(messages)
        end

        private

        attr_reader :text

        def data
          @_data ||= JSON.parse(text, symbolize_names: true)
        end

        def check_errors!
          errors = data[:errors]
          return if errors.nil? || errors.empty?
          fail(ParsingError, "Found #{errors.length} errors in brakeman output")
        end

        def warnings
          data[:warnings] || []
        end

        def message_for(warning)
          path = warning.fetch(:file)
          body = warning.fetch(:message)
          line = warning.fetch(:line)
          level = warning.fetch(:confidence, nil)
          rule = warning.fetch(:warning_type)
          Message.new(path: path, body: body, start_line: line, level: level, rule: rule)
        end
      end
    end
  end
end
