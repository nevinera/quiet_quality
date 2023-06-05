module QuietQuality
  module Colorize
    CODES = {
      red: "\e[31m",
      green: "\e[32m",
      yellow: "\e[33m",
      light_blue: "\e[94m",
      light_cyan: "\e[96m"
    }.freeze

    RESET_CODE = "\e[0m"

    def self.colorize(s, color:)
      fail(ArgumentError, "Unrecognized color '#{color}'") unless CODES.include?(color.to_sym)
      color_code = CODES.fetch(color.to_sym)
      "#{color_code}#{s}#{RESET_CODE}"
    end
  end
end
