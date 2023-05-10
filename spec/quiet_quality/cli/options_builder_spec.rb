RSpec.describe QuietQuality::Cli::OptionsBuilder do
  let(:tool_names) { [:rspec, :rubocop, :standardrb] }
  let(:global_options) { {} }
  let(:tool_options) { {} }
  subject(:builder) { described_class.new(tool_names: tool_names, global_options: global_options, tool_options: tool_options) }

  describe "#options" do
    subject(:options) { builder.options }
    it { is_expected.to be_a(QuietQuality::Cli::Options) }

    describe "#annotator" do
      subject(:annotator) { options.annotator }

      context "when global_options[:annotator] is unset" do
        let(:global_options) { {} }
        it { is_expected.to be_falsey }
      end

      context "when global_options[:annotator] is true" do
        let(:global_options) { {annotator: :github_stdout} }
        it { is_expected.to be_truthy }
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
    end

    describe "#tools" do
      subject(:tools) { options.tools }

      context "when there are no tools specified" do
        let(:tool_names) { [] }

        it "exposes all of the tools" do
          expect(tools.map(&:tool_name)).to contain_exactly(:rspec, :rubocop, :standardrb)
        end
      end

      context "when there are some tools listed" do
        let(:tool_names) { [:rspec, :standardrb] }

        it "exposes the listed tools" do
          expect(tools.map(&:tool_name)).to contain_exactly(:rspec, :standardrb)
        end

        context "and some of them are unrecognized" do
          let(:tool_names) { [:rspec, :barframist, :rubocop] }

          it "raises a UsageError" do
            expect { tools }.to raise_error(QuietQuality::Cli::UsageError, /not recognized/)
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
      end
    end
  end
end
