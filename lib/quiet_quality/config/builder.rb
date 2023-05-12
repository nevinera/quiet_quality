module QuietQuality
  module Config
    class Builder
      def initialize(parsed_cli_options:)
        @cli = parsed_cli_options
      end

      def options
        return @_options if defined?(@_options)
        options = Options.new
        set_annotator(options)
        set_executor(options)
        set_unless_nil(options, :comparison_branch, cli.global_option(:comparison_branch))
        options.tools = tool_names.map { |tool_name| tool_options_for(tool_name) }
        @_options = options
      end

      private

      attr_reader :cli

      def set_unless_nil(object, method, value)
        return if value.nil?
        object.send("#{method}=", value)
      end

      def tool_options_for(tool_name)
        ToolOptions.new(tool_name).tap do |tool_options|
          set_unless_nil(tool_options, :limit_targets, cli.global_option(:limit_targets))
          set_unless_nil(tool_options, :limit_targets, cli.tool_option(tool_name, :limit_targets))

          set_unless_nil(tool_options, :filter_messages, cli.global_option(:filter_messages))
          set_unless_nil(tool_options, :filter_messages, cli.tool_option(tool_name, :filter_messages))
        end
      end

      def tool_names
        if cli.tools.empty?
          Tools::AVAILABLE.keys
        else
          cli.tools.map(&:to_sym)
        end
      end

      def set_annotator(options)
        annotator_name = cli.global_option(:annotator)
        return if annotator_name.nil?
        options.annotator = Annotators::ANNOTATOR_TYPES.fetch(annotator_name)
      end

      def set_executor(options)
        executor_name = cli.global_option(:executor)
        return if executor_name.nil?
        options.executor = Executors::AVAILABLE.fetch(executor_name)
      end
    end
  end
end
