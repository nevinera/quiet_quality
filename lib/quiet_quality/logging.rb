module QuietQuality
  class Logging
    LIGHT = :light
    QUIET = :quiet
    AVAILABLE = [LIGHT, QUIET].freeze

    attr_accessor :level

    def initialize(level: nil)
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
