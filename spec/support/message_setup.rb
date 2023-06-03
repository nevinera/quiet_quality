require "securerandom"

module MessageSetup
  def generate_message_attributes(attrs)
    start_line = attrs.fetch(:start_line, Random.rand(100))
    {
      path: attrs.fetch(:path, "path/#{SecureRandom.alphanumeric(10)}.rb"),
      body: attrs.fetch(:body, "Fake Message: #{SecureRandom.uuid}"),
      start_line: start_line,
      stop_line: attrs.fetch(:stop_line, start_line + Random.rand(4)),
      annotated_line: attrs.fetch(:annotated_line, nil),
      level: attrs.fetch(:level, "Moderate"),
      rule: attrs.fetch(:rule, "FakeRule"),
      tool_name: attrs.fetch(:tool_name, "fake_tool")
    }
  end

  def generate_message(**attrs)
    QuietQuality::Message.load(generate_message_attributes(attrs))
  end

  def generate_messages(count, **attrs)
    count.times.map { generate_message(**attrs) }
  end

  def empty_messages
    QuietQuality::Messages.new([])
  end

  def full_messages(count, **attrs)
    QuietQuality::Messages.new(generate_messages(count, **attrs))
  end
end

RSpec.configure do |config|
  config.include MessageSetup
end
