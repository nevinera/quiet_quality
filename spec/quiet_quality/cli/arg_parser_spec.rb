RSpec.describe QuietQuality::Cli::ArgParser do
  let(:parser) { described_class.new(args) }
  let(:parsed) { parser.parsed_options }

  def expect_global_options(**opts)
    opts.each_pair { |name, value| expect(parsed.global_option(name)).to eq(value) }
  end

  def expect_tool_options(tool, opts)
    opts.each_pair { |name, value| expect(parsed.tool_option(tool, name)).to eq(value) }
  end

  def self.expect_options(desc, arguments, global: {}, **tools)
    context("with #{desc}") do
      let(:args) { arguments }

      it "sets the expected options" do
        expect_global_options(**global) if global.any?
        tools.each_pair do |tool_name, tool_options|
          expect_tool_options(tool_name, tool_options)
        end
      end
    end
  end

  def self.expect_usage_error(desc, arguments, matcher)
    context "with #{desc}" do
      let(:args) { arguments }

      it "raises a UsageError" do
        expect { parsed }.to raise_error(QuietQuality::Cli::UsageError, matcher)
      end
    end
  end

  describe "#help_text" do
    let(:args) { [] }
    subject(:help_text) { parser.help_text }

    it "exposes the correct content" do
      expect(help_text).to eq(<<~HELP_OUTPUT)
        Usage: qq [TOOLS] [GLOBAL_OPTIONS] [TOOL_OPTIONS]
            -h, --help                       Prints this help
            -V, --version                    Print the current version of the gem
            -C, --config PATH                Load a config file from this path
            -N, --no-config                  Do not load a config file, even if present
            -E, --executor EXECUTOR          Which executor to use
            -A, --annotate ANNOTATOR         Annotate with this annotator
            -G, --annotate-github-stdout     Annotate with GitHub Workflow commands
            -a, --all-files [tool]           Use the tool(s) on all files
            -c, --changed-files [tool]       Use the tool(s) only on changed files
            -B, --comparison-branch BRANCH   Specify the branch to compare against
            -f, --filter-messages [tool]     Filter messages from tool(s) based on changed lines
            -u, --unfiltered [tool]          Don't filter messages from tool(s)
            -l, --light                      Print aggregated results only
            -q, --quiet                      Don't print results, only return a status code
      HELP_OUTPUT
    end
  end

  describe "#parsed_options" do
    subject(:parsed_options) { parser.parsed_options }

    describe "help option" do
      context "without --help passed" do
        let(:args) { ["-a"] }
        it { is_expected.not_to be_helping }
      end

      context "with --help passed" do
        let(:args) { ["-a", "--help"] }
        it { is_expected.to be_helping }
      end
    end

    describe "version option" do
      context "without --version passed" do
        let(:args) { ["-a"] }
        it { is_expected.not_to be_printing_version }
      end

      context "with --version passed" do
        let(:args) { ["-a", "--version"] }
        it { is_expected.to be_printing_version }
      end
    end

    describe "parsed tool names" do
      subject(:tool_names) { parsed.tools }

      context "when none are given" do
        let(:args) { ["-a", "-u", "rspec", "-c", "standardrb"] }
        it { is_expected.to be_empty }
      end

      context "when a few are supplied" do
        let(:args) { ["rspec", "standardrb", "-a", "-u", "rspec", "-c", "standardrb"] }
        it { is_expected.to eq([:rspec, :standardrb]) }
      end

      context "when they are mixed in with the flags for some reason" do
        let(:args) { ["-a", "-u", "rspec", "rspec", "-c", "standardrb", "standardrb"] }
        it { is_expected.to eq([:rspec, :standardrb]) }
      end

      context "when invalid tool names are supplied" do
        let(:args) { ["rspec", "foo", "a"] }

        it "raises a UsageError" do
          expect { parsed }.to raise_error(QuietQuality::Cli::UsageError, /Unrecognized tool/)
        end
      end
    end

    describe "config file options" do
      expect_options("(none)", [], global: {config_path: nil, skip_config: nil})
      expect_options("-Cbar.yml", ["-Cbar.yml"], global: {config_path: "bar.yml"})
      expect_options("--config bar.yml", ["--config", "bar.yml"], global: {config_path: "bar.yml"})
      expect_options("-N", ["-N"], global: {no_config: true})
      expect_options("--no-config", ["--no-config"], global: {no_config: true})
    end

    describe "executor options" do
      expect_options("(none)", [], global: {executor: nil})
      expect_options("--executor concurrent", ["--executor", "concurrent"], global: {executor: :concurrent})
      expect_options("--executor serial", ["--executor", "serial"], global: {executor: :serial})
      expect_options("-Econcurrent", ["-Econcurrent"], global: {executor: :concurrent})
      expect_options("-Eserial", ["-Eserial"], global: {executor: :serial})
      expect_usage_error("--executor fooba", ["--executor", "fooba"], /Unrecognized executor/)
      expect_usage_error("-Efooba", ["-Efooba"], /Unrecognized executor/)
    end

    describe "annotation options" do
      expect_options("--annotate github_stdout", ["--annotate", "github_stdout"], global: {annotator: :github_stdout})
      expect_options("-Agithub_stdout", ["-Agithub_stdout"], global: {annotator: :github_stdout})
      expect_options("--annotate-github-stdout", ["--annotate-github-stdout"], global: {annotator: :github_stdout})
      expect_options("-G", ["-G"], global: {annotator: :github_stdout})
      expect_usage_error("--annotate foo_bar", ["--annotate", "foo_bar"], /Unrecognized annotator/i)
      expect_usage_error("-Afoo_bar", ["-Afoo_bar"], /Unrecognized annotator/i)
    end

    describe "logging options" do
      expect_options("-l", ["-l"], global: {logging: :light})
      expect_options("--light", ["--light"], global: {logging: :light})
      expect_options("-q", ["-q"], global: {logging: :quiet})
      expect_options("--quiet", ["--quiet"], global: {logging: :quiet})
      expect_options("-lq", ["-lq"], global: {logging: :quiet})
      expect_options("-ql", ["-ql"], global: {logging: :light})
      expect_options("no logging option passed", [], global: {logging: nil})
    end

    describe "file targeting options" do
      def self.expect_all_files(desc, arguments, globally:, **tools)
        tool_args = tools.each_pair.map { |tool, value| [tool, {all_files: value}] }.to_h
        expect_options(desc, arguments, global: {all_files: globally}, **tool_args)
      end

      expect_all_files("nothing", [], globally: nil, standardrb: nil, rubocop: nil, rspec: nil)
      expect_all_files("--all-files", ["--all-files"], globally: true)
      expect_all_files("-a", ["-a"], globally: true)
      expect_all_files("--changed-files", ["--changed-files"], globally: false)
      expect_all_files("-c", ["-c"], globally: false)
      expect_all_files("--all-files standardrb", ["--all-files", "standardrb"], globally: nil, standardrb: true, rubocop: nil, rspec: nil)
      expect_all_files("-a -crspec", ["-a", "-crspec"], globally: true, rspec: false, standardrb: nil, rubocop: nil)
      expect_all_files("-arspec -crubocop", ["-arspec", "-crubocop"], globally: nil, rspec: true, rubocop: false, standardrb: nil)

      expect_usage_error("--all-files fooba", ["--all-files", "fooba"], /Unrecognized tool/)
      expect_usage_error("-afooba", ["-afooba"], /Unrecognized tool/)
      expect_usage_error("--changed-files fooba", ["--changed-files", "fooba"], /Unrecognized tool/)
      expect_usage_error("-cfooba", ["-cfooba"], /Unrecognized tool/)

      expect_options("nothing", [], global: {comparison_branch: nil})
      expect_options("--comparison-branch trunk", ["--comparison-branch", "trunk"], global: {comparison_branch: "trunk"})
      expect_options("-Btrunk", ["-Btrunk"], global: {comparison_branch: "trunk"})
    end

    describe "filtering options" do
      def self.expect_filter_messages(desc, arguments, globally:, **tools)
        tool_args = tools.each_pair.map { |tool, value| [tool, {filter_messages: value}] }.to_h
        expect_options(desc, arguments, global: {filter_messages: globally}, **tool_args)
      end

      expect_filter_messages("nothing", [], globally: nil, standardrb: nil, rubocop: nil, rspec: nil)
      expect_filter_messages("--filter-messages", ["--filter-messages"], globally: true)
      expect_filter_messages("-f", ["-f"], globally: true)
      expect_filter_messages("--unfiltered", ["--unfiltered"], globally: false)
      expect_filter_messages("-u", ["-u"], globally: false)
      expect_filter_messages("--filter-messages standardrb", ["--filter-messages", "standardrb"], globally: nil, standardrb: true, rubocop: nil, rspec: nil)
      expect_filter_messages("-f -urspec", ["-f", "-urspec"], globally: true, rspec: false, standardrb: nil, rubocop: nil)
      expect_filter_messages("-frspec -urubocop", ["-frspec", "-urubocop"], globally: nil, rspec: true, rubocop: false, standardrb: nil)

      expect_usage_error("--filter-messages fooba", ["--filter-messages", "fooba"], /Unrecognized tool/)
      expect_usage_error("-ffooba", ["-ffooba"], /Unrecognized tool/)
      expect_usage_error("--unfiltered fooba", ["--unfiltered", "fooba"], /Unrecognized tool/)
      expect_usage_error("-ufooba", ["-ufooba"], /Unrecognized tool/)
    end
  end
end
