RSpec.describe QuietQuality::Config::Options do
  subject(:options) { described_class.new }

  it "has the expected default values" do
    expect(options.annotator).to be_nil
    expect(options.executor).to eq(QuietQuality::Executors::ConcurrentExecutor)
    expect(options.comparison_branch).to be_nil
    expect(options.tools).to be_nil
    expect(options.logging).to be_a(QuietQuality::Config::Logging)
  end

  it { is_expected.to respond_to(:tools=) }
  it { is_expected.to respond_to(:annotator=) }
  it { is_expected.to respond_to(:executor=) }
  it { is_expected.to respond_to(:comparison_branch=) }

  describe "#logging=" do
    it "sets the logging level" do
      options.logging = :light
      expect(options.logging.light?).to be true
    end
  end

  describe "#colorize=" do
    it "sets the logging colorization" do
      options.colorize = true
      expect(options.logging.colorize?).to be true
    end
  end
end
