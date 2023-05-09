module QuietQuality
  module Cli
    class OptionsBuilder
      def initialize(tool_names:, global_options:, tool_options:)
        @raw_tool_names = tool_names
        @raw_global_options = global_options
        @raw_tool_options = tool_options
      end

      def options
        return @_options if defined?(@_options)
        options = Options.new
        set_unless_nil(options, :annotator, @raw_global_options[:annotator])
        set_unless_nil(options, :executor, @raw_global_options[:executor])
        options.tools = tool_names.map { |tool_name| tool_options_for(tool_name) }
        @_options = options
      end

      private

      def set_unless_nil(object, method, value)
        return if value.nil?
        object.send("#{method}=", value)
      end

      def tool_options_for(tool_name)
        raw_tool_opts = @raw_tool_options.fetch(tool_name.to_sym, {})
        ToolOptions.new(tool_name).tap do |tool_options|
          set_unless_nil(tool_options, :limit_targets, @raw_global_options[:limit_targets])
          set_unless_nil(tool_options, :limit_targets, raw_tool_opts[:limit_targets])

          set_unless_nil(tool_options, :filter_messages, @raw_global_options[:filter_messages])
          set_unless_nil(tool_options, :filter_messages, raw_tool_opts[:filter_messages])
        end
      end

      def tool_names
        names = @raw_tool_names.empty? ? Tools::AVAILABLE.keys : @raw_tool_names
        names.map(&:to_sym).tap do |names|
          unexpected_names = names - Tools::AVAILABLE.keys
          if unexpected_names.any?
            fail(UsageError, "Tool(s) not recognized: #{unexpected_names.join(", ")}")
          end
        end
      end
    end
  end
end
