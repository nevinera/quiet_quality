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
      rule: attrs.fetch(:rule, "FakeRule")
    }
  end

  def generate_message(**attrs)
    QuietQuality::Message.new(**generate_message_attributes(attrs))
  end

  def generate_messages(count, **attrs)
    count.times.map { generate_message(**attrs) }
  end
end

RSpec.configure do |config|
  config.include MessageSetup
end
