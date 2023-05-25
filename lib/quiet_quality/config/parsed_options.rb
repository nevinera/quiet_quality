module QuietQuality
  module Config
    class ParsedOptions
      def initialize
        @tools = []
        @tool_options = {}
        @global_options = {}
        @helping = @printing_version = false
      end

      attr_accessor :tools
      attr_writer :helping, :printing_version

      def helping?
        @helping
      end

      def printing_version?
        @printing_version
      end

      def set_global_option(name, value)
        @global_options[name.to_sym] = value
      end

      def global_option(name)
        @global_options.fetch(name.to_sym, nil)
      end

      def set_tool_option(tool, name, value)
        @tool_options[tool.to_sym] ||= {}
        @tool_options[tool.to_sym][name.to_sym] = value
      end

      def tool_option(tool, name)
        @tool_options.dig(tool.to_sym, name.to_sym)
      end
    end
  end
end
