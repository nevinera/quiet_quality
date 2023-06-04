module QuietQuality
  module Config
    class Logging
      LIGHT = :light
      QUIET = :quiet
      NORMAL = :normal
      LEVELS = [LIGHT, QUIET, NORMAL].freeze

      attr_accessor :level

      def initialize(level: NORMAL)
        @level = level
      end

      def light?
        @level == LIGHT
      end

      def quiet?
        @level == QUIET
      end
    end
  end
end
