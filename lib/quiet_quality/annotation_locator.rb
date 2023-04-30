module QuietQuality
  class AnnotationLocator
    def initialize(changed_files:)
      @changed_files = changed_files
    end

    def update!(message)
      changed_file = changed_files.file(message.path)
      message.annotated_line = changed_file ? file_line_for(message, changed_file) : nil
    end

    def update_all!(messages)
      messages.map { |m| update!(m) }.compact.length
    end

    private

    attr_reader :changed_files

    def file_line_for(message, changed_file)
      message_range = (message.start_line..message.stop_line)
      last_match(changed_file.line_numbers, message_range)
    end

    def last_match(array, range)
      array.reverse_each do |value|
        return value if range.cover?(value)
      end
      nil
    end
  end
end
