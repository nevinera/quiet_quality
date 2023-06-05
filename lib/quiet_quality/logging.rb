module QuietQuality
  module Logging
    def warn(message, data: nil)
      logger.warn(message, data: data)
    end

    def info(message, data: nil)
      logger.info(message, data: data)
    end

    def debug(message, data: nil)
      logger.debug(message, data: data)
    end

    private

    def logger
      QuietQuality.logger
    end
  end
end
