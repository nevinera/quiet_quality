module QuietQuality
  module Config
    class Builder
      def initialize(parsed_cli_options:)
        @cli = parsed_cli_options
      end

      def options
        return @_options if defined?(@_options)
        options = build_initial_options
        Updater.new(options: options, apply: config_file).update! if config_file
        Updater.new(options: options, apply: cli).update!
        @_options = options
      end

      private

      attr_reader :cli

      def build_initial_options
        tools = tool_names.map { |name| ToolOptions.new(name) }
        Options.new.tap { |opts| opts.tools = tools }
      end

      def specified_tool_names
        if cli.tools.any?
          cli.tools
        elsif config_file&.tools&.any?
          config_file.tools
        else
          []
        end
      end

      def exec_tool_name
        cli.global_option(:exec_tool)
      end

      def tool_names
        (specified_tool_names + [exec_tool_name]).compact.uniq
      end

      def config_finder
        @_config_finder ||= Finder.new(from: ".")
      end

      def config_path
        return @_config_path if defined?(@_config_path)

        @_config_path =
          if cli.global_option(:no_config)
            nil
          elsif cli.global_option(:config_path)
            cli.global_option(:config_path)
          elsif config_finder.config_path
            config_finder.config_path
          end
      end

      def config_file
        return @_parsed_config_options if defined?(@_parsed_config_options)

        if config_path
          parser = Parser.new(config_path)
          @_parsed_config_options = parser.parsed_options
        else
          @_parsed_config_options = nil
        end
      end

      class Updater
        def initialize(options:, apply:)
          @options, @apply = options, apply
        end

        def update!
          update_globals
          update_tools
        end

        private

        attr_reader :options, :apply

        def set_unless_nil(object, method, value)
          return if value.nil?
          object.send("#{method}=", value)
        end

        # ---- update the global options -------------

        def update_globals
          update_annotator
          update_executor
          update_exec_tool
          update_comparison_branch
          update_logging
        end

        def update_annotator
          annotator_name = apply.global_option(:annotator)
          return if annotator_name.nil?
          options.annotator = Annotators::ANNOTATOR_TYPES.fetch(annotator_name)
        end

        def update_executor
          executor_name = apply.global_option(:executor)
          return if executor_name.nil?
          options.executor = Executors::AVAILABLE.fetch(executor_name)
        end

        def update_exec_tool
          set_unless_nil(options, :exec_tool, apply.global_option(:exec_tool))
        end

        def update_comparison_branch
          set_unless_nil(options, :comparison_branch, apply.global_option(:comparison_branch))
        end

        def update_logging
          set_unless_nil(options, :logging, apply.global_option(:logging))
          set_unless_nil(options, :colorize, apply.global_option(:colorize))
          set_unless_nil(options, :message_format, apply.global_option(:message_format))
        end

        # ---- update the tool options (apply global forms first) -------

        def update_tools
          options.tools.each do |tool_options|
            update_tool_option(tool_options, :limit_targets)
            update_tool_option(tool_options, :filter_messages)
            update_tool_option(tool_options, :file_filter)
          end
        end

        def update_tool_option(tool_options, option_name)
          tool_name = tool_options.tool_name
          set_unless_nil(tool_options, option_name, apply.global_option(option_name))
          set_unless_nil(tool_options, option_name, apply.tool_option(tool_name, option_name))
        end
      end
    end
  end
end
