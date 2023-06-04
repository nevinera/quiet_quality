RSpec.describe QuietQuality::Config::Logging do
  subject(:logging) { described_class.new(level: level) }

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
end
