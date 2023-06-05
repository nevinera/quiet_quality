module LoggerMocking
  def expect_logged(level, message, data: nil)
    expect(QuietQuality.logger).to have_received(level).with(message, data: data)
  end

  def expect_warn(message, data: nil)
    expect_logged(:warn, message, data: data)
  end

  def expect_info(message, data: nil)
    expect_logged(:info, message, data: data)
  end

  def expect_debug(message, data: nil)
    expect_logged(:debug, message, data: data)
  end

  def expect_not_logged(level, regex)
    expect(QuietQuality.logger)
      .not_to have_received(level)
      .with(a_string_matching(regex), data: anything)
  end
end

RSpec.configure do |config|
  config.before do
    allow(QuietQuality.logger).to receive(:info)
    allow(QuietQuality.logger).to receive(:warn)
    allow(QuietQuality.logger).to receive(:debug)
    allow(QuietQuality.logger).to receive(:increase_level!)
  end

  config.include LoggerMocking
end
