module QuietQuality
  module Config
    class Parser
      InvalidConfig = Class.new(Config::Error)

      def initialize(path)
        @path = path
      end

      def parsed_options
        @_parsed_options ||= ParsedOptions.new.tap do |opts|
          store_default_tools(opts)
          store_global_options(opts)
          store_tool_options(opts)
        end
      end

      private

      attr_reader :path

      def text
        @_text ||= File.read(path)
      end

      def data
        @_data ||= YAML.safe_load(text, symbolize_names: true)
      end

      def store_default_tools(opts)
        tool_names = data.fetch(:default_tools, [])
        invalid!("default_tools must be an array") unless tool_names.is_a?(Array)
        tool_names.each do |name|
          invalid!("each default tool must be a string") unless name.is_a?(String)
          invalid!("unrecognized tool name '#{name}'") unless valid_tool?(name)
        end
        opts.tools = tool_names.map(&:to_sym)
      end

      def store_global_options(opts)
        read_global_option(opts, :executor, :executor, as: :symbol, validate_from: Executors::AVAILABLE)
        read_global_option(opts, :annotator, :annotator, as: :symbol, validate_from: Annotators::ANNOTATOR_TYPES)
        read_global_option(opts, :annotate, :annotator, as: :symbol, validate_from: Annotators::ANNOTATOR_TYPES)
        read_global_option(opts, :comparison_branch, :comparison_branch, as: :string)
        read_global_option(opts, :changed_files, :limit_targets, as: :boolean)
        read_global_option(opts, :all_files, :limit_targets, as: :reversed_boolean)
        read_global_option(opts, :filter_messages, :filter_messages, as: :boolean)
        read_global_option(opts, :unfiltered, :filter_messages, as: :reversed_boolean)
        read_global_option(opts, :colorize, :colorize, as: :boolean)
        read_global_option(opts, :logging, :logging, as: :symbol, validate_from: Options::LOGGING_LEVELS)
        read_global_option(opts, :message_format, :message_format, as: :string)
      end

      def store_tool_options(opts)
        Tools::AVAILABLE.keys.each do |tool_name|
          store_tool_options_for(opts, tool_name)
        end
      end

      def store_tool_options_for(opts, tool_name)
        entries = data.fetch(tool_name, nil)
        return if entries.nil?

        read_tool_option(opts, tool_name, :filter_messages, :filter_messages, as: :boolean)
        read_tool_option(opts, tool_name, :unfiltered, :filter_messages, as: :reversed_boolean)
        read_tool_option(opts, tool_name, :changed_files, :limit_targets, as: :boolean)
        read_tool_option(opts, tool_name, :all_files, :limit_targets, as: :reversed_boolean)
        read_tool_option(opts, tool_name, :file_filter, :file_filter, as: :string)
        read_tool_option(opts, tool_name, :excludes, :excludes, as: :strings)
        read_tool_option(opts, tool_name, :command, :command, as: :strings)
        read_tool_option(opts, tool_name, :exec_command, :exec_command, as: :strings)
      end

      def invalid!(message)
        fail(InvalidConfig, message)
      end

      def valid_tool?(name)
        Tools::AVAILABLE.key?(name.to_sym)
      end

      def valid_boolean?(value)
        [true, false].include?(value)
      end

      def read_global_option(opts, name, into, as:, validate_from: nil)
        parsed_value = data.fetch(name.to_sym, nil)
        return if parsed_value.nil?

        validate_value(name, parsed_value, as: as, from: validate_from)
        coerced_value = coerce_value(parsed_value, as: as)
        opts.set_global_option(into, coerced_value)
      end

      def read_tool_option(opts, tool, name, into, as:)
        parsed_value = data.dig(tool.to_sym, name.to_sym)
        return if parsed_value.nil?

        validate_value("#{tool}.#{name}", parsed_value, as: as)
        coerced_value = coerce_value(parsed_value, as: as)
        opts.set_tool_option(tool, into, coerced_value)
      end

      def validate_value(name, value, as:, from: nil)
        case as
        when :boolean then validate_boolean(name, value)
        when :reversed_boolean then validate_boolean(name, value)
        when :symbol then validate_symbol(name, value, from: from)
        when :string then validate_string(name, value)
        when :strings then validate_strings(name, value)
        end
      end

      def validate_boolean(name, value)
        return if valid_boolean?(value)
        invalid!("option #{name} must be either true or false")
      end

      def validate_symbol(name, value, from: nil)
        unless value.is_a?(String) || value.is_a?(Symbol)
          invalid!("option #{name} must be a string or symbol")
        end

        unless from.nil? || from.include?(value.to_sym)
          allowed_list = from.respond_to?(:keys) ? from.keys : from
          allowed_string = allowed_list.map(&:to_s).join(", ")
          invalid!("option #{name} must be one of the allowed values: #{allowed_string}")
        end
      end

      def validate_string(name, value)
        invalid!("option #{name} must be a string") unless value.is_a?(String)
        invalid!("option #{name} must not be empty") if value.empty?
      end

      def validate_strings(name, value)
        invalid!("option #{name} must be an array") unless value.is_a?(Array)
        value.each_with_index { |item, n| validate_string("#{name}[#{n}]", item) }
      end

      def coerce_value(value, as:)
        case as
        when :boolean then !!value
        when :reversed_boolean then !value
        when :string then value.to_s
        when :strings then value.map(&:to_s)
        when :symbol then value.to_sym
        end
      end
    end
  end
end
