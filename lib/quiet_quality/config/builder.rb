module QuietQuality
  module Config
    class Builder
      def initialize(tool_names:, global_options:, tool_options:)
        @raw_tool_names = tool_names
        @raw_global_options = global_options
        @raw_tool_options = tool_options
      end

      def options
        return @_options if defined?(@_options)
        options = Options.new
        set_annotator(options)
        set_executor(options)
        set_unless_nil(options, :comparison_branch, @raw_global_options[:comparison_branch])
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
        if @raw_tool_names.empty?
          Tools::AVAILABLE.keys
        else
          @raw_tool_names.map(&:to_sym)
        end
      end

      def set_annotator(options)
        annotator_name = @raw_global_options[:annotator]
        return if annotator_name.nil?
        options.annotator = Annotators::ANNOTATOR_TYPES.fetch(annotator_name)
      end

      def set_executor(options)
        executor_name = @raw_global_options[:executor]
        return if executor_name.nil?
        options.executor = Executors::AVAILABLE.fetch(executor_name)
      end
    end
  end
end
