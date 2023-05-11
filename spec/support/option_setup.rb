module OptionSetup
  def tool_options(tool, **args)
    QuietQuality::Config::ToolOptions.new(tool, **args)
  end
end

RSpec.configure do |config|
  config.include OptionSetup
end
