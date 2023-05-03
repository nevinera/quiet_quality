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

    def merge(other)
      if path != other.path
        fail ArgumentError, "Cannot merge ChangedFiles '#{path}' and '#{other.path}', they're different files"
      end

      return self.class.new(path: path, lines: :all) if entire? || other.entire?
      self.class.new(path: path, lines: (lines + other.lines).to_a)
    end
  end
end
