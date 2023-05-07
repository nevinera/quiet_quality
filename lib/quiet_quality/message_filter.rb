module QuietQuality
  class MessageFilter
    def initialize(changed_files:)
      @changed_files = changed_files
    end

    def relevant?(message)
      return false unless changed_files.include?(message.path)

      file = changed_files.file(message.path)
      return true if file.entire?

      relevant_lines?(message, file)
    end

    def filter(messages)
      Messages.new(messages.select { |m| relevant?(m) })
    end

    private

    attr_reader :changed_files

    def relevant_lines?(message, file)
      if message.stop_line == message.start_line
        file.lines.include?(message.start_line)
      else
        message_range = (message.start_line..message.stop_line)
        file.line_numbers.any? { |n| message_range.cover?(n) }
      end
    end
  end
end
