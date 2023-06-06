module QuietQuality
  class Logger
    LEVEL_UPS = {none: :warn, warn: :info, info: :debug}.freeze
    LEVELS = {none: 0, warn: 1, info: 2, debug: 3}.freeze
    COLORS = {warn: :yellow, info: :light_blue, debug: :light_cyan}.freeze

    def initialize(level: :warn, stream: $stderr)
      @level = level
      @stream = stream
    end

    attr_reader :level

    def increase_level!
      next_level = LEVEL_UPS.fetch(level, nil)
      self.level = next_level if next_level
    end

    def show?(message_level)
      LEVELS[message_level] <= LEVELS[level]
    end

    def level=(name)
      fail(ArgumentError, "Unrecognized Logger level '#{name}'") unless LEVELS.include?(name.to_sym)
      @level = name.to_sym
    end

    def warn(message, data: nil)
      log_message(message, data, :warn)
    end

    def info(message, data: nil)
      log_message(message, data, :info)
    end

    def debug(message, data: nil)
      log_message(message, data, :debug)
    end

    private

    attr_reader :stream

    def log_message(message, data, message_level)
      return unless show?(message_level)
      stream.puts formatted_message(message, data, message_level)
      stream.flush
    end

    def formatted_message(message, data, message_level)
      prefix = message_level.to_s.upcase.rjust(5)
      if data
        data_text = JSON.pretty_generate(data)
        message = message + "\n" + data_text
      end
      prefixed_message = message.split("\n").map { |line| "[#{prefix}] #{line}" }.join("\n")
      colorize(prefixed_message, message_level)
    end

    def colorize(s, message_level)
      color = COLORS.fetch(message_level)
      Colorize.colorize(s, color: color)
    end
  end
end
