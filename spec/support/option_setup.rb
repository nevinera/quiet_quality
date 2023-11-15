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

  def build_options(**attrs)
    opts = QuietQuality::Config::Options.new
    maybe_set_option(opts, attrs, :comparison_branch)
    maybe_set_option(opts, attrs, :logging)
    maybe_set_option(opts, attrs, :colorize)
    maybe_set_option(opts, attrs, :annotator, :annotator_from)
    maybe_set_option(opts, attrs, :executor, :executor_from)
    maybe_set_option(opts, attrs, :exec_tool)
    opts.tools = tool_options_from(attrs)
    opts
  end

  private

  def maybe_set_option(opts, attrs, key, transform = nil)
    value = attrs[key]
    return if value.nil?

    value = send(transform, value) if transform
    opts.send("#{key}=", value)
  end

  def set_global_options(po, global_options)
    global_options.each_pair { |name, value| po.set_global_option(name, value) }
  end

  def set_tool_options(po, tool_options)
    tool_options.each_pair do |tool, specifics|
      specifics.each_pair { |name, value| po.set_tool_option(tool, name, value) }
    end
  end

  def annotator_from(name)
    QuietQuality::Annotators::ANNOTATOR_TYPES.fetch(name)
  end

  def executor_from(name)
    QuietQuality::Executors::AVAILABLE.fetch(name)
  end

  def tool_options_from(attrs)
    tool_options = []
    QuietQuality::Tools::AVAILABLE.each_key do |tool_name|
      tool_options << tool_options(tool_name, **attrs[tool_name]) if attrs[tool_name]
    end
    tool_options
  end
end

RSpec.configure do |config|
  config.include OptionSetup
end
