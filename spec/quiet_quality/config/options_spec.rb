RSpec.describe QuietQuality::Config::Options do
  subject(:options) { described_class.new }

  it "has the expected default values" do
    expect(options.annotator).to be_nil
    expect(options.executor).to eq(QuietQuality::Executors::ConcurrentExecutor)
    expect(options.exec_tool).to be_nil
    expect(options.tools).to be_nil
    expect(options.comparison_branch).to be_nil
    expect(options.colorize?).to be(true)
    expect(options.logging).to eq(:normal)
    expect(options.message_format).to be_nil
  end

  it { is_expected.to respond_to(:tools=) }
  it { is_expected.to respond_to(:annotator=) }
  it { is_expected.to respond_to(:executor=) }
  it { is_expected.to respond_to(:exec_tool=) }
  it { is_expected.to respond_to(:comparison_branch=) }
  it { is_expected.to respond_to(:colorize=) }
  it { is_expected.to respond_to(:message_format=) }

  describe "#logging=" do
    it "updates the logging value" do
      expect { options.logging = :light }
        .to change(options, :logging)
        .from(:normal).to(:light)
    end

    it "rejects an unrecognized level" do
      expect { options.logging = :ultra }
        .to raise_error(ArgumentError, /Unrecognized logging level 'ultra'/)
    end

    it "accepts a string" do
      expect { options.logging = "quiet" }
        .to change(options, :logging)
        .from(:normal).to(:quiet)
    end
  end

  describe "#colorize?" do
    subject(:colorize?) { options.colorize? }

    context "by default" do
      it { is_expected.to be_truthy }
    end

    context "when set to false" do
      before { options.colorize = false }
      it { is_expected.to be_falsey }
    end
  end

  describe "#quiet?" do
    subject(:quiet?) { options.quiet? }

    context "when set to :light" do
      before { options.logging = :light }
      it { is_expected.to be_falsey }
    end

    context "when set to :quiet" do
      before { options.logging = :quiet }
      it { is_expected.to be_truthy }
    end
  end

  describe "#light?" do
    subject(:light?) { options.light? }

    context "when set to :light" do
      before { options.logging = :light }
      it { is_expected.to be_truthy }
    end

    context "when set to :quiet" do
      before { options.logging = :quiet }
      it { is_expected.to be_falsey }
    end
  end

  describe "#to_h" do
    let(:options) { build_options(colorize: true, rspec: {limit_targets: true}, standardrb: {filter_messages: false}) }
    subject(:to_h) { options.to_h }

    it "produces the expected data" do
      expect(to_h).to eq({
        annotator: nil,
        colorize: true,
        comparison_branch: nil,
        executor: "QuietQuality::Executors::ConcurrentExecutor",
        exec_tool: nil,
        logging: :normal,
        message_format: nil,
        tools: {
          rspec: {
            tool_name: :rspec,
            file_filter: nil,
            excludes: nil,
            filter_messages: true,
            limit_targets: true
          },
          standardrb: {
            tool_name: :standardrb,
            file_filter: nil,
            excludes: nil,
            filter_messages: false,
            limit_targets: true
          }
        }
      })
    end
  end
end
