require "optparse"

module QuietQuality
  module Cli
    class ArgParser
      def initialize(args)
        @args = args
        @parsed_options = Config::ParsedOptions.new
        @parsed = false
      end

      def parsed_options
        unless @parsed
          parser.parse!(@args)
          @parsed_options.tools = validated_tool_names(@args.dup)
          @parsed = true
        end
        @parsed_options
      end

      def help_text
        @_help_text ||= parser.to_s
      end

      private

      def set_global_option(name, value)
        @parsed_options.set_global_option(name, value)
      end

      def set_tool_option(tool, name, value)
        @parsed_options.set_tool_option(tool, name, value)
      end

      def validate_value_from(name, value, allowed)
        return if allowed.include?(value.to_sym)
        fail(UsageError, "Unrecognized #{name}: #{value}")
      end

      def validated_tool_names(names)
        names.each { |name| validate_value_from("tool", name, Tools::AVAILABLE) }
      end

      # There are several flags that _may_ take a 'tool' argument - if they do, they are tool
      # options; if they don't, they are global options. (optparse allows an optional argument
      # to a flag if the string representing it is not a 'string in all caps'. So `[FOO]` or `foo`
      # would be optional, but `FOO` would be required. This helper simplifies handling those.
      def read_tool_or_global_option(name, tool, value)
        if tool
          validate_value_from("tool", tool, Tools::AVAILABLE)
          set_tool_option(tool, name, value)
        else
          set_global_option(name, value)
        end
      end

      # -- Set up the option parser itself -------------------------

      def parser
        @_parser ||= ::OptionParser.new do |parser|
          setup_banner(parser)
          setup_help_output(parser)
          setup_executor_options(parser)
          setup_annotation_options(parser)
          setup_file_target_options(parser)
          setup_filter_messages_options(parser)
        end
      end

      def setup_banner(parser)
        parser.banner = "Usage: qq [TOOLS] [GLOBAL_OPTIONS] [TOOL_OPTIONS]"
      end

      def setup_help_output(parser)
        parser.on("-h", "--help", "Prints this help") do
          @parsed_options.helping = true
        end
      end

      def setup_executor_options(parser)
        parser.on("-E", "--executor EXECUTOR", "Which executor to use") do |name|
          validate_value_from("executor", name, Executors::AVAILABLE)
          set_global_option(:executor, name.to_sym)
        end
      end

      def setup_annotation_options(parser)
        parser.on("-A", "--annotate ANNOTATOR", "Annotate with this annotator") do |name|
          validate_value_from("annotator", name, Annotators::ANNOTATOR_TYPES)
          set_global_option(:annotator, name.to_sym)
        end

        # shortcut option
        parser.on("-G", "--annotate-github-stdout", "Annotate with GitHub Workflow commands") do
          set_global_option(:annotator, :github_stdout)
        end
      end

      def setup_file_target_options(parser)
        parser.on("-a", "--all-files [tool]", "Use the tool(s) on all files") do |tool|
          read_tool_or_global_option(:all_files, tool, true)
        end

        parser.on("-c", "--changed-files [tool]", "Use the tool(s) only on changed files") do |tool|
          read_tool_or_global_option(:all_files, tool, false)
        end

        parser.on("-B", "--comparison-branch BRANCH", "Specify the branch to compare against") do |branch|
          set_global_option(:comparison_branch, branch)
        end
      end

      def setup_filter_messages_options(parser)
        parser.on("-f", "--filter-messages [tool]", "Filter messages from tool(s) based on changed lines") do |tool|
          read_tool_or_global_option(:filter_messages, tool, true)
        end

        parser.on("-u", "--unfiltered [tool]", "Don't filter messages from tool(s)") do |tool|
          read_tool_or_global_option(:filter_messages, tool, false)
        end
      end
    end
  end
end