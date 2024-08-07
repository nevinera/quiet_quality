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
        limit_targets: true,
        filter_messages: false,
        logging: :light
      )
      expect_tool_options(
        rspec: {filter_messages: false, limit_targets: false},
        standardrb: {filter_messages: true, limit_targets: nil, file_filter: nil},
        rubocop: {filter_messages: nil, limit_targets: false, file_filter: nil}
      )

      it "parsed the rspec file_filter properly" do
        expect(parsed_options.tool_option("rspec", "file_filter")).to eq("spec/.*_spec.rb")
        expect(parsed_options.tool_option("rspec", "excludes"))
          .to contain_exactly("^db/schema\\.rb", "^db/seeds\\.rb")
      end
    end

    context "with a mocked configuration file" do
      let(:path) { "/tmp/fake/file.yml" }
      before { allow(File).to receive(:read).and_call_original }
      before { allow(File).to receive(:read).with(path).and_return(yaml) }

      context "that is simple but correct" do
        let(:yaml) { "{changed_files: true}" }
        it { is_expected.to be_a(QuietQuality::Config::ParsedOptions) }
        expect_global_options(limit_targets: true, executor: nil, annotator: nil)
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
        expect_config "no settings", %({}), globals: {limit_targets: nil}, tools: {rspec: {limit_targets: nil}}
        expect_config "a global changed_files", %({changed_files: true}), globals: {limit_targets: true}, tools: {rspec: {limit_targets: nil}}
        expect_config "an rspec changed_files", %({rspec: {changed_files: false}}), globals: {limit_targets: nil}, tools: {rspec: {limit_targets: false}}
        expect_config "a global all_files", %({all_files: false}), globals: {limit_targets: true}, tools: {rspec: {limit_targets: nil}}
        expect_config "an rspec all_files", %({rspec: {all_files: true}}), globals: {limit_targets: nil}, tools: {rspec: {limit_targets: false}}
        expect_config "both changed_files", %({changed_files: true, rspec: {changed_files: false}}), globals: {limit_targets: true}, tools: {rspec: {limit_targets: false}}
        expect_config "both all_files", %({all_files: false, rspec: {all_files: true}}), globals: {limit_targets: true}, tools: {rspec: {limit_targets: false}}
        expect_invalid "a non-boolean changed_files", %({changed_files: "yeah"}), /either true or false/
      end

      describe "filter_messages parsing" do
        expect_config "no settings", %({}), globals: {filter_messages: nil}, tools: {rspec: {filter_messages: nil}}
        expect_config "a global filter_messages", %({filter_messages: true}), globals: {filter_messages: true}, tools: {rspec: {filter_messages: nil}}
        expect_config "an rspec filter_messages", %({rspec: {filter_messages: false}}), globals: {filter_messages: nil}, tools: {rspec: {filter_messages: false}}
        expect_config "a global unfiltered", %({unfiltered: false}), globals: {filter_messages: true}, tools: {rspec: {filter_messages: nil}}
        expect_config "an rspec unfiltered", %({rspec: {unfiltered: true}}), globals: {filter_messages: nil}, tools: {rspec: {filter_messages: false}}
        expect_config "both filter_messages", %({filter_messages: true, rspec: {filter_messages: false}}), globals: {filter_messages: true}, tools: {rspec: {filter_messages: false}}
        expect_config "both unfiltered", %({unfiltered: false, rspec: {unfiltered: true}}), globals: {filter_messages: true}, tools: {rspec: {filter_messages: false}}
        expect_invalid "a non-boolean filter_messages", %({filter_messages: "yeah"}), /either true or false/
      end

      describe "logging parsing" do
        expect_config "no logging", %({}), globals: {comparison_branch: nil, colorize: nil}
        expect_config "the valid 'light' logging option", %({logging: "light"}), globals: {logging: :light}
        expect_config "the valid 'quiet' logging option", %({logging: "quiet"}), globals: {logging: :quiet}
        expect_config "the valid 'normal' logging option", %({logging: "normal"}), globals: {logging: :normal}
        expect_invalid "a numeric logging option", %({logging: 5}), /must be a string/
        expect_invalid "an empty logging option", %({logging: ""}), /option logging must be one of the allowed values/
        expect_invalid "an invalid logging option", %({logging: shecklackity}), /option logging must be one of the allowed values/
        expect_config "colorization enabled", %({colorize: true}), globals: {colorize: true}
        expect_config "colorization disabled", %({colorize: false}), globals: {colorize: false}
        expect_config "message_format unset", %({}), globals: {message_format: nil}
        expect_config "message_format set", %({message_format: "foo"}), globals: {message_format: "foo"}
      end

      describe "file_filter parsing" do
        expect_config "no settings", %({}), tools: {rspec: {file_filter: nil}, rubocop: {file_filter: nil}}

        context "with a config that has an rspec file_filter" do
          let(:yaml) { %({rspec: {file_filter: "^spec/"}}) }

          it "has the expected file_filters set" do
            expect(parsed_options.tool_option("rspec", "file_filter")).to eq("^spec/")
            expect(parsed_options.tool_option("rspec", "excludes")).to be_nil
            expect(parsed_options.tool_option("rubocop", "file_filter")).to be_nil
            expect(parsed_options.tool_option("rubocop", "excludes")).to be_nil
          end
        end

        context "with a config that has rubocop excludes set" do
          let(:yaml) { %({rubocop: {excludes: ["foo", "bar"]}}) }

          it "has the expected file_filters set" do
            expect(parsed_options.tool_option("rubocop", "excludes")).to contain_exactly("foo", "bar")
            expect(parsed_options.tool_option("rubocop", "file_filter")).to be_nil
            expect(parsed_options.tool_option("rspec", "excludes")).to be_nil
            expect(parsed_options.tool_option("rspec", "file_filter")).to be_nil
          end
        end

        expect_invalid "an invalid tool file_filter", %({rspec: {file_filter: 2}}), /must be a string/
        expect_invalid "an invalid tool excludes", %({rspec: {excludes: "foo"}}), /must be an array/
        expect_invalid "an invalid tool excludes", %({rspec: {excludes: ["a",2]}}), /must be a string/
      end

      describe "command parsing" do
        expect_config "no settings", %({}), tools: {rspec: {command: nil}, rubocop: {command: nil}}

        context "with a config that has an rspec command supplied" do
          let(:yaml) { %({rspec: {command: ["foo", "bar", "baz"]}}) }

          it "has the expected commands set" do
            expect(parsed_options.tool_option("rspec", "command")).to eq(["foo", "bar", "baz"])
            expect(parsed_options.tool_option("rubocop", "command")).to be_nil
          end
        end

        context "with multiple configs with commands supplied" do
          let(:yaml) { %({rspec: {command: ["a", "b"]}, rubocop: {command: ["c", "d"]}}) }

          it "has the expected commands set" do
            expect(parsed_options.tool_option("rspec", "command")).to eq(["a", "b"])
            expect(parsed_options.tool_option("rubocop", "command")).to eq(["c", "d"])
          end
        end
      end

      describe "exec_command parsing" do
        expect_config "no settings", %({}), tools: {rspec: {exec_command: nil}, rubocop: {exec_command: nil}}

        context "with a config that has an rspec exec_command supplied" do
          let(:yaml) { %({rspec: {exec_command: ["foo", "bar", "baz"]}}) }

          it "has the expected exec_commands set" do
            expect(parsed_options.tool_option("rspec", "exec_command")).to eq(["foo", "bar", "baz"])
            expect(parsed_options.tool_option("rubocop", "exec_command")).to be_nil
          end
        end

        context "with multiple configs with exec_commands supplied" do
          let(:yaml) { %({rspec: {exec_command: ["a", "b"]}, rubocop: {exec_command: ["c", "d"]}}) }

          it "has the expected exec_commands set" do
            expect(parsed_options.tool_option("rspec", "exec_command")).to eq(["a", "b"])
            expect(parsed_options.tool_option("rubocop", "exec_command")).to eq(["c", "d"])
          end
        end
      end
    end
  end
end
