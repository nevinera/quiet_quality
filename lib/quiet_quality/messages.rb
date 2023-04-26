module QuietQuality
  class Messages
    attr_reader :messages

    def initialize(messages)
      @messages = messages
    end

    def to_hashes
      messages.map(&:to_h)
    end

    def to_json(pretty: false)
      pretty ? JSON.pretty_generate(to_hashes) : JSON.generate(to_hashes)
    end

    def to_yaml
      to_hashes.to_yaml
    end
  end
end
