RSpec.describe QuietQuality::Cli::ArgParser do
  let(:parser) { described_class.new(args) }
  let(:parsed) { parser.parse! }
  let(:parsed_positionals) { parsed[0] }
  let(:parsed_options) { parsed[1] }
  let(:parsed_tool_options) { parsed[2] }

  def expect_global_options(**opts)
    opts.each_pair { |name, value| expect(parsed_options[name]).to eq(value) }
  end

  def expect_tool_options(tool, opts)
    tool_options = parsed_tool_options[tool] || {}
    opts.each_pair { |name, value| expect(tool_options[name]).to eq(value) }
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
        expect { parser.parse! }.to raise_error(QuietQuality::Cli::UsageError, matcher)
      end
    end
  end

  describe "help option" do
    let(:args) { ["--help"] }

    it "sets exit_immediately to true" do
      expect(parsed_options[:exit_immediately]).to be_truthy
    end

    it "sets the output as expected" do
      parser.parse!
      expect(parser.output).to eq(<<~HELP_OUTPUT)
        Usage: qq [TOOLS] [GLOBAL_OPTIONS] [TOOL_OPTIONS]
            -h, --help                       Prints this help
            -E, --executor EXECUTOR          Which executor to use
            -A, --annotate ANNOTATOR         Annotate with this annotator
            -G, --annotate-github-stdout     Annotate with GitHub Workflow commands
            -a, --all-files [tool]           Use the tool(s) on all files
            -c, --changed-files [tool]       Use the tool(s) only on changed files
            -B, --comparison-branch BRANCH   Specify the branch to compare against
            -f, --filter-messages [tool]     Filter messages from tool(s) based on changed lines
            -u, --unfiltered [tool]          Don't filter messages from tool(s)
      HELP_OUTPUT
    end
  end

  describe "executor options" do
    subject(:executor_option) { parsed[1][:executor] }
    expect_options("(none)", [], global: {executor: :concurrent})
    expect_options("--executor concurrent", ["--executor", "concurrent"], global: {executor: :concurrent})
    expect_options("--executor serial", ["--executor", "serial"], global: {executor: :serial})
    expect_options("-Econcurrent", ["-Econcurrent"], global: {executor: :concurrent})
    expect_options("-Eserial", ["-Eserial"], global: {executor: :serial})
    expect_usage_error("--executor fooba", ["--executor", "fooba"], /not recognized/)
    expect_usage_error("-Efooba", ["-Efooba"], /not recognized/)
  end

  describe "annotation options" do
    subject(:annotation_option) { parsed[1][:annotator] }
    expect_options("--annotate github_stdout", ["--annotate", "github_stdout"], global: {annotator: :github_stdout})
    expect_options("-Agithub_stdout", ["-Agithub_stdout"], global: {annotator: :github_stdout})
    expect_options("--annotate-github-stdout", ["--annotate-github-stdout"], global: {annotator: :github_stdout})
    expect_options("-G", ["-G"], global: {annotator: :github_stdout})
    expect_usage_error("--annotate foo_bar", ["--annotate", "foo_bar"], /not recognized/i)
    expect_usage_error("-Afoo_bar", ["-Afoo_bar"], /not recognized/i)
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
  end
end
