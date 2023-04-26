module QuietQuality
  class Message
    attr_reader :path, :body, :start_line, :stop_line, :annotated_line, :level, :rule

    def self.load(hash)
      new(**hash)
    end

    def initialize(**attrs)
      @attrs = attrs
      @path = attrs.fetch(:path)
      @body = attrs.fetch(:body)
      @start_line = attrs.fetch(:start_line)
      @stop_line = attrs.fetch(:stop_line, @start_line)
      @annotated_line = attrs.fetch(:annotated_line, @stop_line)
      @level = attrs.fetch(:level, nil)
      @rule = attrs.fetch(:rule, nil)
    end

    def to_h
      @attrs.map { |k, v| [k.to_s, v] }.to_h
    end
  end
end
