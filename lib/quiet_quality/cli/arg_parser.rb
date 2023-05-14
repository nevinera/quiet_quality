require "optparse"

module QuietQuality
  module Cli
    class ArgParser
      attr_reader :options, :tool_options, :output

      def initialize(args)
        @args = args
        @options = {
          executor: :concurrent
        }
        @tool_options = {}
        @output = nil
      end

      def parse!
        parser.parse!(@args)
        [positional, options, tool_options]
      end

      def positional
        @args
      end

      private

      def parser
        ::OptionParser.new do |parser|
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
          @output = parser.to_s
          @options[:exit_immediately] = true
        end
      end

      def setup_executor_options(parser)
        parser.on("-E", "--executor EXECUTOR", "Which executor to use") do |name|
          validate_value_from("executor", name, Executors::AVAILABLE)
          @options[:executor] = name.to_sym
        end
      end

      def setup_annotation_options(parser)
        parser.on("-A", "--annotate ANNOTATOR", "Annotate with this annotator") do |name|
          validate_value_from("annotator", name, Annotators::ANNOTATOR_TYPES)
          @options[:annotator] = name.to_sym
        end

        # shortcut option
        parser.on("-G", "--annotate-github-stdout", "Annotate with GitHub Workflow commands") do
          @options[:annotator] = :github_stdout
        end
      end

      def read_tool_or_global_option(name, tool, value)
        if tool
          validate_value_from("tool", tool, Tools::AVAILABLE)
          @tool_options[tool.to_sym] ||= {}
          @tool_options[tool.to_sym][name] = value
        else
          @options[name] = value
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
          @options[:comparison_branch] = branch
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

      def validate_value_from(name, value, allowed)
        return if allowed.include?(value.to_sym)
        fail(UsageError, "Unrecognized #{name}: #{value}")
      end
    end
  end
end
