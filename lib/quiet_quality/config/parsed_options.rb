module QuietQuality
  module Config
    class ParsedOptions
      InvalidOptionName = Class.new(Error)

      GLOBAL_OPTIONS = [
        :no_config,
        :config_path,
        :annotator,
        :executor,
        :exec_tool,
        :comparison_branch,
        :colorize,
        :logging,
        :message_format,
        :limit_targets,
        :filter_messages,
        :file_filter
      ].to_set

      TOOL_OPTIONS = [
        :limit_targets,
        :filter_messages,
        :file_filter
      ].to_set

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
        validate_global_option(name)
        @global_options[name.to_sym] = value
      end

      def global_option(name)
        validate_global_option(name)
        @global_options.fetch(name.to_sym, nil)
      end

      def set_tool_option(tool, name, value)
        validate_tool_option(name)
        @tool_options[tool.to_sym] ||= {}
        @tool_options[tool.to_sym][name.to_sym] = value
      end

      def tool_option(tool, name)
        validate_tool_option(name)
        @tool_options.dig(tool.to_sym, name.to_sym)
      end

      private

      def validate_global_option(name)
        return if GLOBAL_OPTIONS.include?(name.to_sym)
        fail(InvalidOptionName, "Option name #{name} is not a recognized global ParsedOption")
      end

      def validate_tool_option(name)
        return if TOOL_OPTIONS.include?(name.to_sym)
        fail(InvalidOptionName, "Option name #{name} is not a recognized tool ParsedOption")
      end
    end
  end
end
