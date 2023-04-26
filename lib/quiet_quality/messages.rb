module QuietQuality
  class Messages
    include Enumerable

    def self.load_data(data)
      messages = data.map { |message_data| Message.new(**message_data) }
      new(messages)
    end

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

    def all
      messages
    end

    def each(&block)
      if block
        messages.each(&block)
      else
        to_enum(:each)
      end
    end

    private

    attr_reader :messages
  end
end
