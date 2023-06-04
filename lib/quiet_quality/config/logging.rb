module QuietQuality
  module Config
    class Logging
      LIGHT = :light
      QUIET = :quiet
      NORMAL = :normal
      LEVELS = [LIGHT, QUIET, NORMAL].freeze

      attr_accessor :level, :colorize

      def initialize(level: NORMAL, colorize: nil)
        @level = level
        @colorize = colorize
      end

      def light?
        @level == LIGHT
      end

      def quiet?
        @level == QUIET
      end

      def colorize?
        @colorize
      end
    end
  end
end
