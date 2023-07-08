require "optparse"

module QuietQuality
  module Cli
    class ExecArgParser
      def initialize(args)
        @args = args
        @parsed_options = Config::ParsedOptions.new
        @parsed = false
      end

      def parsed_options
        unless @parsed
          parser.parse!(@args)
          @parsed_options.tools = [validated_tool_name(@args.dup).to_sym]
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

      def validated_tool_name(remaining_serial_args)
        return if helping? || printing_version?
        fail(UsageError, "A tool name must be supplied") if remaining_serial_args.length < 1
        fail(UsageError, "Only one tool name may be supplied") if remaining_serial_args.length > 1
        remaining_serial_args.first.tap do |name|
          validate_value_from("tool", name, Tools::AVAILABLE)
        end
      end

      # -- Set up the option parser itself -------------------------

      def parser
        @_parser ||= ::OptionParser.new do |parser|
          setup_banner(parser)
          setup_help_output(parser)
          setup_config_options(parser)
          setup_file_target_options(parser)
          setup_colorization_options(parser)
          setup_logging_options(parser)
          setup_verbosity_options(parser)
        end
      end

      def setup_banner(parser)
        parser.banner = "Usage: qqe TOOL [GLOBAL_OPTIONS] [TOOL_OPTIONS]"
      end

      def setup_help_output(parser)
        parser.on("-h", "--help", "Prints this help") do
          @parsed_options.helping = true
        end

        parser.on("-V", "--version", "Print the current version of the gem") do
          @parsed_options.printing_version = true
        end
      end

      def setup_config_options(parser)
        parser.on("-C", "--config PATH", "Load a config file from this path") do |path|
          set_global_option(:config_path, path)
        end

        parser.on("-N", "--no-config", "Do not load a config file, even if present") do
          set_global_option(:no_config, true)
        end
      end

      def setup_file_target_options(parser)
        parser.on("-a", "--all-files", "Use the tool on all files") do |tool|
          set_global_option(:limit_targets, false)
        end

        parser.on("-c", "--changed-files", "Use the tool only on changed files") do |tool|
          set_global_option(:limit_targets, true)
        end

        parser.on("-B", "--comparison-branch BRANCH", "Specify the branch to compare against") do |branch|
          set_global_option(:comparison_branch, branch)
        end
      end

      def setup_colorization_options(parser)
        parser.on("--[no-]colorize", "Colorize the logging output") do |value|
          set_global_option(:colorize, value)
        end
      end

      def setup_logging_options(parser)
        parser.on("-n", "--normal", "Print outcomes and messages") do
          set_global_option(:logging, :normal)
        end

        parser.on("-l", "--light", "Print aggregated results only") do
          set_global_option(:logging, :light)
        end

        parser.on("-q", "--quiet", "Don't print results, only return a status code") do
          set_global_option(:logging, :quiet)
        end

        parser.on("-L", "--logging LEVEL", "Specify logging mode (from normal/light/quiet)") do |level|
          validate_value_from("logging level", level.to_sym, Config::Options::LOGGING_LEVELS)
          set_global_option(:logging, level.to_sym)
        end
      end

      def setup_verbosity_options(parser)
        parser.on("-v", "--verbose", "Log more verbosely - multiple times is more verbose") do
          QuietQuality.logger.increase_level!
        end
      end
    end
  end
end
