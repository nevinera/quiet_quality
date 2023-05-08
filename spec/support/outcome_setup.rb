module OutcomeSetup
  def build_outcome(output:, logging: nil, failure: false)
    QuietQuality::Tools::Outcome.new(output: output, logging: logging, failure: failure)
  end

  def build_success(output, logging = nil)
    build_outcome(output: output, logging: logging, failure: false)
  end

  def build_failure(output, logging = nil)
    build_outcome(output: output, logging: logging, failure: true)
  end
end

RSpec.configure do |config|
  config.include OutcomeSetup
end
