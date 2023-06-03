module QuietQuality
  class Message
    attr_writer :annotated_line

    def self.load(hash)
      new(**hash)
    end

    def initialize(**attrs)
      @attrs = attrs.map { |k, v| [k.to_s, v] }.to_h
    end

    def to_h
      @attrs.map { |k, v| [k.to_s, v] }.to_h
    end

    def path
      @_path ||= @attrs.fetch("path")
    end

    def body
      @_body ||= @attrs.fetch("body")
    end

    def start_line
      @_start_line ||= @attrs.fetch("start_line")
    end

    def stop_line
      @_stop_line ||= @attrs.fetch("stop_line", start_line)
    end

    def annotated_line
      @annotated_line ||= @attrs.fetch("annotated_line", nil)
    end

    def level
      @_level ||= @attrs.fetch("level", nil)
    end

    def rule
      @_rule ||= @attrs.fetch("rule", nil)
    end

    def tool_name
      @_tool_name ||= @attrs.fetch("tool_name")
    end
  end
end
