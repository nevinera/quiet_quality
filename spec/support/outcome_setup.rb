module OutcomeSetup
  def build_outcome(tool:, output:, logging: nil, failure: false)
    QuietQuality::Tools::Outcome.new(tool: tool, output: output, logging: logging, failure: failure)
  end

  def build_success(tool, output, logging = nil)
    build_outcome(tool: tool, output: output, logging: logging, failure: false)
  end

  def build_failure(tool, output, logging = nil)
    build_outcome(tool: tool, output: output, logging: logging, failure: true)
  end
end

RSpec.configure do |config|
  config.include OutcomeSetup
end
