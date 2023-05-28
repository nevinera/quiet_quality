RSpec.describe QuietQuality::Logging do
  describe "#light?" do
    subject { described_class.new(level: level).light? }

    context "level is nil" do
      let(:level) { nil }
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
    subject { described_class.new(level: level).quiet? }

    context "level is nil" do
      let(:level) { nil }
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
      expect(described_class.new.level).to be_nil
    end
  end

  describe "#level=" do
    it "sets the level" do
      logging = described_class.new
      expect { logging.level = :light }.to change { logging.level }.from(nil).to(:light)
    end
  end
end
