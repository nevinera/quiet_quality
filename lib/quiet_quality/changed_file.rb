module QuietQuality
  class ChangedFile
    attr_reader :path

    def initialize(path:, lines:)
      @path = path

      if lines == :all || lines == "all"
        @entire = true
        @lines = nil
      else
        @entire = false
        @lines = lines
      end
    end

    def entire?
      @entire
    end

    def lines
      return nil if @lines.nil?
      @_lines ||= @lines.to_set
    end

    def line_numbers
      return nil if @lines.nil?
      @_line_numbers ||= @lines.sort
    end
  end
end
