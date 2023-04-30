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
  end
end
