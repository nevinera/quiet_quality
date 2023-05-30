module QuietQuality
  class Logger
    def initialize(stream:, logging:)
      @stream = stream
      @logging = logging
    end

    def puts(s)
      return if logging.quiet?
      stream.puts(s)
    end

    private

    attr_reader :stream, :logging
  end
end
