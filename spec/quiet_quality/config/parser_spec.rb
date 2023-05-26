RSpec.describe QuietQuality::Config::Parser do
  subject(:parser) { described_class.new(path) }

  describe "#parsed_options" do
    subject(:parsed_options) { parser.parsed_options }

    def self.expect_default_tools(*tools)
      it "has the expected default tools set" do
        expect(parsed_options.tools).to match_array(tools)
      end
    end

    def self.expect_global_options(expected_options)
      it "has the expected global options set" do
        expected_options.each_pair do |name, value|
          expect(parsed_options.global_option(name)).to eq(value)
        end
      end
    end

    def self.expect_tool_options(tool_options)
      it "has the expected tool options set" do
        tool_options.each_pair do |tool_name, topts|
          topts.each_pair do |name, value|
            expect(parsed_options.tool_option(tool_name, name)).to eq(value)
          end
        end
      end
    end

    def self.expect_invalid(description, config, matcher)
      context "with a config that is invalid because of #{description}" do
        let(:yaml) { config }

        it "raises the expected InvalidConfig" do
          expect { parsed_options }
            .to raise_error(QuietQuality::Config::Parser::InvalidConfig, matcher)
        end
      end
    end

    def self.expect_config(description, config, defaults: nil, globals: nil, tools: nil)
      context "with a config that has #{description}" do
        let(:yaml) { config }
        expect_default_tools(*defaults) if defaults
        expect_global_options(globals) if globals
        expect_tool_options(tools) if tools
      end
    end

    context "with a complex and valid configuration file" do
      let(:path) { fixture_path("configs", "valid.yml") }
      it { is_expected.to be_a(QuietQuality::Config::ParsedOptions) }
      expect_default_tools(:standardrb, :rubocop)
      expect_global_options(
        executor: :concurrent,
        annotator: nil,
        comparison_branch: "master",
        changed_files: true,
        filter_messages: false
      )
      expect_tool_options(
        rspec: {filter_messages: false, changed_files: false},
        standardrb: {filter_messages: true, changed_files: nil},
        rubocop: {filter_messages: nil, changed_files: false}
      )
    end

    context "with a mocked configuration file" do
      let(:path) { "/tmp/fake/file.yml" }
      before { allow(File).to receive(:read).and_call_original }
      before { allow(File).to receive(:read).with(path).and_return(yaml) }

      context "that is simple but correct" do
        let(:yaml) { "{changed_files: true}" }
        it { is_expected.to be_a(QuietQuality::Config::ParsedOptions) }
        expect_global_options(changed_files: true, executor: nil, annotator: nil)
      end

      describe "the default_tools parsing" do
        expect_config "an array of known tools", %({default_tools: ["rspec", "rubocop"]}), defaults: [:rspec, :rubocop]
        expect_invalid "a non-array default_tools value", %({default_tools: "rspec"}), /must be an array/
        expect_invalid "a non-string default_tools entry", %({default_tools: ["rspec", 3]}), /must be a string/
        expect_invalid "an unrecognized default_tools entry", %({default_tools: ["foo"]}), /unrecognized tool/
      end

      describe "executor parsing" do
        expect_config "no executor", %({}), globals: {executor: nil}
        expect_config "a concurrent executor", %({executor: "concurrent"}), globals: {executor: :concurrent}
        expect_config "a serial executor", %({executor: "serial"}), globals: {executor: :serial}
        expect_invalid "a fooba executor", %({executor: "fooba"}), /one of the allowed values/
        expect_invalid "a numeric executor", %({executor: 5}), /string or symbol/
      end

      describe "annotator parsing" do
        expect_config "no annotator", %({}), globals: {annotator: nil}
        expect_config "a github_stdout annotator", %({annotator: "github_stdout"}), globals: {annotator: :github_stdout}
        expect_invalid "a fooba annotator", %({annotator: "fooba"}), /one of the allowed values/
        expect_invalid "a numeric annotator", %({annotator: 5}), /string or symbol/
        expect_config "a github_stdout annotate", %({annotate: "github_stdout"}), globals: {annotator: :github_stdout}
        expect_invalid "a fooba annotate", %({annotate: "fooba"}), /one of the allowed values/
      end

      describe "comparison_branch parsing" do
        expect_config "no comparison_branch", %({}), globals: {comparison_branch: nil}
        expect_config "a comparison_branch", %({comparison_branch: "main"}), globals: {comparison_branch: "main"}
        expect_invalid "a numeric comparison_branch", %({comparison_branch: 5}), /must be a string/
        expect_invalid "an empty comparison_branch", %({comparison_branch: ""}), /must not be empty/
      end

      describe "changed_files parsing" do
        expect_config "no settings", %({}), globals: {changed_files: nil}, tools: {rspec: {changed_files: nil}}
        expect_config "a global changed_files", %({changed_files: true}), globals: {changed_files: true}, tools: {rspec: {changed_files: nil}}
        expect_config "an rspec changed_files", %({rspec: {changed_files: false}}), globals: {changed_files: nil}, tools: {rspec: {changed_files: false}}
        expect_config "an rspec changed_files", %({rspec: {changed_files: false}}), globals: {changed_files: nil}, tools: {rspec: {changed_files: false}}
        expect_config "both changed_files", %({changed_files: true, rspec: {changed_files: false}}), globals: {changed_files: true}, tools: {rspec: {changed_files: false}}
        expect_config "global all_files", %({all_files: false, rspec: {changed_files: false}}), globals: {changed_files: true}, tools: {rspec: {changed_files: false}}
        expect_invalid "a non-boolean changed_files", %({changed_files: "yeah"}), /either true or false/
      end

      describe "filter_messages parsing" do
        expect_config "no settings", %({}), globals: {filter_messages: nil}, tools: {rspec: {filter_messages: nil}}
        expect_config "a global filter_messages", %({filter_messages: true}), globals: {filter_messages: true}, tools: {rspec: {filter_messages: nil}}
        expect_config "an rspec filter_messages", %({rspec: {filter_messages: false}}), globals: {filter_messages: nil}, tools: {rspec: {filter_messages: false}}
        expect_config "an rspec filter_messages", %({rspec: {filter_messages: false}}), globals: {filter_messages: nil}, tools: {rspec: {filter_messages: false}}
        expect_config "both filter_messages", %({filter_messages: true, rspec: {filter_messages: false}}), globals: {filter_messages: true}, tools: {rspec: {filter_messages: false}}
        expect_config "global unfiltered", %({unfiltered: false, rspec: {filter_messages: false}}), globals: {filter_messages: true}, tools: {rspec: {filter_messages: false}}
        expect_invalid "a non-boolean filter_messages", %({filter_messages: "yeah"}), /either true or false/
      end
    end
  end
end
