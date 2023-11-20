RSpec.describe QuietQuality::Config::Builder do
  let(:tool_names) { [:rspec, :rubocop, :standardrb] }
  let(:global_options) { {} }
  let(:tool_options) { {} }
  let(:parsed_cli) { parsed_options(tools: tool_names, global_options: global_options, tool_options: tool_options) }
  subject(:builder) { described_class.new(parsed_cli_options: parsed_cli) }

  let(:cfg_tool_names) { [:rspec, :rubocop] }
  let(:cfg_global_options) { {} }
  let(:cfg_tool_options) { {} }
  let(:parsed_config_file) { parsed_options(tools: cfg_tool_names, global_options: cfg_global_options, tool_options: cfg_tool_options) }
  let(:fake_parser) { instance_double(QuietQuality::Config::Parser, parsed_options: parsed_config_file) }
  before { allow(QuietQuality::Config::Parser).to receive(:new).and_return(fake_parser) }

  let(:found_path) { nil }
  let(:fake_finder) { instance_double(QuietQuality::Config::Finder, config_path: found_path) }
  before { allow(QuietQuality::Config::Finder).to receive(:new).and_return(fake_finder) }

  describe "#options" do
    subject(:options) { builder.options }
    it { is_expected.to be_a(QuietQuality::Config::Options) }

    describe "#annotator" do
      subject(:annotator) { options.annotator }

      context "when global_options[:annotator] is unset" do
        let(:global_options) { {} }
        it { is_expected.to be_nil }
      end

      context "when global_options[:annotator] is true" do
        let(:global_options) { {annotator: :github_stdout} }
        it { is_expected.to eq(QuietQuality::Annotators::GithubStdout) }
      end

      context "when a config file is passed" do
        let(:global_options) { {config_path: "/fake.yml"} }

        context "when the config file sets the annotator" do
          let(:cfg_global_options) { {annotator: :github_stdout} }
          it { is_expected.to eq(QuietQuality::Annotators::GithubStdout) }
        end
      end
    end

    describe "#executor" do
      subject(:executor) { options.executor }

      context "when global_options[:executor] is unset" do
        let(:global_options) { {} }
        it { is_expected.to eq(QuietQuality::Executors::ConcurrentExecutor) }
      end

      context "when global_options[:executor] is concurrent" do
        let(:global_options) { {executor: :concurrent} }
        it { is_expected.to eq(QuietQuality::Executors::ConcurrentExecutor) }
      end

      context "when global_options[:executor] is serial" do
        let(:global_options) { {executor: :serial} }
        it { is_expected.to eq(QuietQuality::Executors::SerialExecutor) }
      end

      context "when a config file is passed" do
        let(:global_options) { {config_path: "/fake.yml", executor: cli_executor} }

        context "when the config file sets the executor" do
          let(:cfg_global_options) { {executor: :concurrent} }

          context "and the cli does not" do
            let(:cli_executor) { nil }
            it { is_expected.to eq(QuietQuality::Executors::ConcurrentExecutor) }
          end

          context "and the cli sets a different one" do
            let(:cli_executor) { :serial }
            it { is_expected.to eq(QuietQuality::Executors::SerialExecutor) }
          end
        end
      end
    end

    describe "#exec_tool" do
      subject(:exec_tool) { options.exec_tool }

      context "when global_options[:exec_tool] is unset" do
        let(:global_options) { {} }
        it { is_expected.to be_nil }
      end

      context "when global_options[:exec_tool] is :rspec" do
        let(:global_options) { {exec_tool: :rspec} }
        it { is_expected.to eq(:rspec) }
      end
    end

    describe "#comparison_branch" do
      subject(:comparison_branch) { options.comparison_branch }

      context "when global_options[:comparison_branch] is unset" do
        let(:global_options) { {} }
        it { is_expected.to be_nil }
      end

      context "when global_options[:comparison_branch] is specified" do
        let(:global_options) { {comparison_branch: "my-comparison-branch"} }
        it { is_expected.to eq("my-comparison-branch") }
      end

      context "when a config file is passed" do
        let(:global_options) { {config_path: "/fake.yml", comparison_branch: cli_comparison_branch} }

        context "when the config file sets the executor" do
          let(:cfg_global_options) { {comparison_branch: "main"} }

          context "and the cli does not" do
            let(:cli_comparison_branch) { nil }
            it { is_expected.to eq("main") }
          end

          context "and the cli sets a different one" do
            let(:cli_comparison_branch) { "master" }
            it { is_expected.to eq("master") }
          end
        end
      end
    end

    describe "#logging" do
      subject(:logging) { options.logging }

      context "when global_options[:logging] is unset" do
        let(:global_options) { {} }
        it { is_expected.to eq(:normal) }
      end

      context "when global_options[:logging] is specified" do
        let(:global_options) { {logging: :quiet} }
        it { is_expected.to eq(:quiet) }
      end

      context "when a config file is passed" do
        let(:global_options) { {config_path: "/fake.yml", logging: cli_logging} }

        context "when the config file sets the logging" do
          let(:cfg_global_options) { {logging: :light} }

          context "and the cli does not" do
            let(:cli_logging) { nil }
            it { is_expected.to eq(:light) }
          end

          context "and the cli sets a different one" do
            let(:cli_logging) { :quiet }
            it { is_expected.to eq(:quiet) }
          end
        end
      end
    end

    describe "#colorize" do
      subject(:colorize?) { options.colorize? }

      context "when global_options[:colorize] is unset" do
        let(:global_options) { {} }
        it { is_expected.to be_truthy }
      end

      context "when global_options[:colorize] is specified as true" do
        let(:global_options) { {colorize: true} }
        it { is_expected.to be_truthy }
      end

      context "when global_options[:colorize] is specified as false" do
        let(:global_options) { {colorize: false} }
        it { is_expected.to be_falsey }
      end

      context "when a config file is passed" do
        let(:global_options) { {config_path: "/fake.yml", colorize: cli_colorize}.compact }

        context "when the config file sets colorize" do
          let(:cfg_global_options) { {colorize: false} }

          context "and the cli does not" do
            let(:cli_colorize) { nil }
            it { is_expected.to be_falsey }
          end

          context "and the cli sets it differently" do
            let(:cli_colorize) { true }
            it { is_expected.to be_truthy }
          end
        end
      end
    end

    describe "#message_format" do
      subject(:message_format) { options.message_format }

      context "when global_options[:message_format] is unset" do
        let(:global_options) { {} }
        it { is_expected.to be_nil }
      end

      context "when global_options[:message_format] is specified" do
        let(:global_options) { {message_format: "foobar"} }
        it { is_expected.to eq("foobar") }
      end

      context "when a config file is passed" do
        let(:global_options) { {config_path: "/fake.yml", message_format: cli_message_format}.compact }

        context "when the config file sets message_format" do
          let(:cfg_global_options) { {message_format: "barbaz"} }

          context "and the cli does not" do
            let(:cli_message_format) { nil }
            it { is_expected.to eq("barbaz") }
          end

          context "and the cli sets it differently" do
            let(:cli_message_format) { "foobaz" }
            it { is_expected.to eq("foobaz") }
          end
        end
      end
    end

    describe "#tools" do
      subject(:tools) { options.tools }

      context "when there are no tools specified on the cli" do
        let(:tool_names) { [] }

        it { is_expected.to be_empty }

        context "but there are some specified in a config file" do
          let(:global_options) { {config_path: "fake.yml"} }
          let(:cfg_tool_names) { [:rspec, :rubocop] }

          it "uses the config file values" do
            expect(tools.map(&:tool_name)).to contain_exactly(:rspec, :rubocop)
          end
        end
      end

      context "when there are some tools listed on the cli" do
        let(:tool_names) { [:rspec, :standardrb] }

        it "exposes the listed tools" do
          expect(tools.map(&:tool_name)).to contain_exactly(:rspec, :standardrb)
        end

        context "and others listed in a supplied config file" do
          let(:global_options) { {config_path: "fake.yml"} }
          let(:cfg_tool_names) { [:rspec, :rubocop] }

          it "uses the cli values" do
            expect(tools.map(&:tool_name)).to contain_exactly(:rspec, :standardrb)
          end
        end
      end

      context "when exec_tool is supplied" do
        let(:global_options) { {exec_tool: :rspec} }

        context "and no tools are specified on the cli" do
          let(:tool_names) { [] }

          it "treats the exec_tool as a listed tool" do
            expect(tools.map(&:tool_name)).to contain_exactly(:rspec)
          end
        end

        context "and some tools are specified on the cli" do
          context "but it is not one of them" do
            let(:tool_names) { [:standardrb] }

            it "adds the exec_tool to the listed tools" do
              expect(tools.map(&:tool_name)).to contain_exactly(:rspec, :standardrb)
            end
          end

          context "and it is one of them" do
            let(:tool_names) { [:rspec, :standardrb] }

            it "does not change the listed tools" do
              expect(tools.map(&:tool_name)).to contain_exactly(:rspec, :standardrb)
            end
          end
        end
      end

      describe "#limit_targets" do
        let(:rspec_tool_option) { tools.detect { |t| t.tool_name == :rspec } }
        subject(:rspec_limit_targets) { rspec_tool_option.limit_targets? }

        context "with no options" do
          let(:global_options) { {} }
          it { is_expected.to be_truthy }
        end

        context "while globally disabled" do
          let(:global_options) { {limit_targets: false} }
          it { is_expected.to be_falsey }

          context "but specifically enabled" do
            let(:tool_options) { {rspec: {limit_targets: true}} }
            it { is_expected.to be_truthy }
          end
        end

        context "while globally enabled" do
          let(:global_options) { {limit_targets: true} }
          it { is_expected.to be_truthy }

          context "but specifically disabled" do
            let(:tool_options) { {rspec: {limit_targets: false}} }
            it { is_expected.to be_falsey }
          end
        end

        context "when a config file is supplied" do
          let(:cli_limit_targets) { nil }
          let(:global_options) { {config_path: "fake.yml", limit_targets: cli_limit_targets} }

          context "when the config file specifically enables it" do
            let(:cfg_tool_options) { {rspec: {limit_targets: true}} }

            context "and the cli doesn't care" do
              let(:tool_options) { {} }
              it { is_expected.to be_truthy }
            end

            context "but the cli globally disables it" do
              let(:cli_limit_targets) { false }
              it { is_expected.to be_falsey }
            end

            context "but the cli specifically disables it" do
              let(:tool_options) { {rspec: {limit_targets: false}} }
              it { is_expected.to be_falsey }
            end
          end
        end
      end

      describe "#filter_messages" do
        let(:rspec_tool_option) { tools.detect { |t| t.tool_name == :rspec } }
        subject(:rspec_filter_messages) { rspec_tool_option.filter_messages? }

        context "with no options" do
          let(:global_options) { {} }
          it { is_expected.to be_truthy }
        end

        context "while globally disabled" do
          let(:global_options) { {filter_messages: false} }
          it { is_expected.to be_falsey }

          context "but specifically enabled" do
            let(:tool_options) { {rspec: {filter_messages: true}} }
            it { is_expected.to be_truthy }
          end
        end

        context "while globally enabled" do
          let(:global_options) { {filter_messages: true} }
          it { is_expected.to be_truthy }

          context "but specifically disabled" do
            let(:tool_options) { {rspec: {filter_messages: false}} }
            it { is_expected.to be_falsey }
          end
        end

        context "when a config file is supplied" do
          let(:cli_filter_messages) { nil }
          let(:global_options) { {config_path: "fake.yml", filter_messages: cli_filter_messages} }

          context "when the config file specifically enables it" do
            let(:cfg_tool_options) { {rspec: {filter_messages: true}} }

            context "and the cli doesn't care" do
              let(:tool_options) { {} }
              it { is_expected.to be_truthy }
            end

            context "but the cli globally disables it" do
              let(:cli_filter_messages) { false }
              it { is_expected.to be_falsey }
            end

            context "but the cli specifically disables it" do
              let(:tool_options) { {rspec: {filter_messages: false}} }
              it { is_expected.to be_falsey }
            end
          end
        end
      end

      describe "#file_filter" do
        let(:rspec_tool_option) { tools.detect { |t| t.tool_name == :rspec } }
        subject(:rspec_file_filter) { rspec_tool_option.file_filter }

        context "with no config file supplied" do
          it { is_expected.to be_nil }
        end

        context "with a config file supplied" do
          let(:global_options) { {config_path: "fake.yml"} }
          let(:file_filter) { QuietQuality::Config::FileFilter.new(regex: ".*", excludes: ["foo", "bar"]) }

          context "when the config file sets it" do
            let(:cfg_tool_options) { {rspec: {file_filter: ".*", excludes: ["foo", "bar"]}} }
            it { is_expected.to eq(file_filter) }
          end

          context "when the config file does not set it" do
            let(:cfg_tool_options) { {rspec: {filter_messages: false}} }
            it { is_expected.to be_nil }
          end
        end
      end
    end

    describe "config_file parsing" do
      shared_examples "config file is parsed" do |expected_path|
        it "parsed the expected config file" do
          options
          expect(QuietQuality::Config::Parser).to have_received(:new).with(expected_path)
          expect(fake_parser).to have_received(:parsed_options)
        end
      end

      shared_examples "config file is not parsed" do
        it "does not parse the config file" do
          options
          expect(QuietQuality::Config::Parser).not_to have_received(:new)
          expect(fake_parser).not_to have_received(:parsed_options)
        end
      end

      context "when config_path is supplied through the cli" do
        let(:global_options) { {config_path: "/fake.yml"} }
        include_examples "config file is parsed", "/fake.yml"

        context "but no_config is passed" do
          let(:global_options) { {config_path: "/fake.yml", no_config: true} }
          include_examples "config file is not parsed"
        end
      end

      context "when the config_finder finds a config_path" do
        let(:found_path) { "/found.yml" }
        include_examples "config file is parsed", "/found.yml"

        context "but a config_path is also supplied on the cli" do
          let(:global_options) { {config_path: "/fake.yml"} }
          include_examples "config file is parsed", "/fake.yml"
        end

        context "but no_config is passed" do
          let(:global_options) { {config_path: "/fake.yml", no_config: true} }
          include_examples "config file is not parsed"
        end
      end

      context "when no config_path is available" do
        include_examples "config file is not parsed"
      end
    end
  end
end
