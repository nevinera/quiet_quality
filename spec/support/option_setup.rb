module OptionSetup
  def tool_options(tool, **args)
    QuietQuality::Config::ToolOptions.new(tool, **args)
  end

  def parsed_options(global_options: {}, tool_options: {}, **attrs)
    po = QuietQuality::Config::ParsedOptions.new
    po.tools = attrs.fetch(:tools, [])
    po.helping = attrs.fetch(:helping, false)
    po.printing_version = attrs.fetch(:printing_version, false)
    set_global_options(po, global_options)
    set_tool_options(po, tool_options)
    po
  end

  private

  def set_global_options(po, global_options)
    global_options.each_pair { |name, value| po.set_global_option(name, value) }
  end

  def set_tool_options(po, tool_options)
    tool_options.each_pair do |tool, specifics|
      specifics.each_pair { |name, value| po.set_tool_option(tool, name, value) }
    end
  end
end

RSpec.configure do |config|
  config.include OptionSetup
end
