module QuietQuality
  class ChangedFile
    attr_reader :path

    def initialize(path:, lines:)
      @path = path
      @lines = lines
    end

    def lines
      @_lines ||= @lines.to_set
    end

    def line_numbers
      @_line_numbers ||= @lines.sort
    end
  end
end
