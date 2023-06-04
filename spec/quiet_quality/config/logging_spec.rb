RSpec.describe QuietQuality::Config::Logging do
  let(:level) { described_class::NORMAL }
  let(:colorize) { true }
  subject(:logging) { described_class.new(level: level, colorize: colorize) }

  describe "#light?" do
    subject { logging.light? }

    context "level is not supplied" do
      let(:logging) { described_class.new }
      it { is_expected.to be(false) }
    end

    context "level is :normal" do
      let(:level) { described_class::NORMAL }
      it { is_expected.to be(false) }
    end

    context "level is :light" do
      let(:level) { described_class::LIGHT }
      it { is_expected.to be(true) }
    end

    context "level is :quiet" do
      let(:level) { described_class::QUIET }
      it { is_expected.to be(false) }
    end
  end

  describe "#quiet?" do
    subject { logging.quiet? }

    context "level is not supplied" do
      let(:logging) { described_class.new }
      it { is_expected.to be(false) }
    end

    context "level is :normal" do
      let(:level) { described_class::NORMAL }
      it { is_expected.to be(false) }
    end

    context "level is :light" do
      let(:level) { described_class::LIGHT }
      it { is_expected.to be(false) }
    end

    context "level is :quiet" do
      let(:level) { described_class::QUIET }
      it { is_expected.to be(true) }
    end
  end

  describe "#level" do
    it "returns the level" do
      expect(described_class.new(level: :light).level).to eq(:light)
      expect(described_class.new(level: :quiet).level).to eq(:quiet)
      expect(described_class.new.level).to eq(:normal)
    end
  end

  describe "#level=" do
    let(:level) { described_class::NORMAL }

    it "sets the level" do
      expect { logging.level = :light }
        .to change { logging.level }
        .from(:normal).to(:light)
    end
  end

  describe "#colorize?" do
    subject(:colorize?) { logging.colorize? }

    context "when not supplied" do
      let(:logging) { described_class.new }
      it { is_expected.to be_truthy }
    end

    context "when supplied as false" do
      let(:colorize) { false }
      it { is_expected.to be_falsey }
    end

    context "when supplied as true" do
      let(:colorize) { true }
      it { is_expected.to be_truthy }
    end

    it "can be changed after creation" do
      expect { logging.colorize = false }
        .to change { logging.colorize? }
        .from(true).to(false)
    end
  end
end
