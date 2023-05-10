RSpec.describe QuietQuality::Tools::Outcome do
  let(:tool) { :foo_tool }
  let(:failure) { false }
  let(:output) { "fake output" }
  let(:logging) { "fake logging" }
  subject(:outcome) { described_class.new(tool: tool, output: output, logging: logging, failure: failure) }

  describe "#failure?" do
    subject(:failure?) { outcome.failure? }

    context "when failure: true" do
      let(:failure) { true }
      it { is_expected.to be_truthy }
    end

    context "when failure: false" do
      let(:failure) { false }
      it { is_expected.to be_falsey }
    end
  end

  describe "#success?" do
    subject(:success?) { outcome.success? }

    context "when failure: true" do
      let(:failure) { true }
      it { is_expected.to be_falsey }
    end

    context "when failure: false" do
      let(:failure) { false }
      it { is_expected.to be_truthy }
    end
  end

  describe "#==" do
    let(:other) { build_outcome(tool: other_tool, output: other_output, logging: other_logging, failure: other_failure) }
    subject(:equality) { outcome == other }

    let(:other_tool) { tool }
    let(:other_output) { output }
    let(:other_logging) { logging }
    let(:other_failure) { failure }

    context "when all match" do
      it { is_expected.to be_truthy }
    end

    context "when tool is different" do
      let(:other_tool) { :bar_tool }
      it { is_expected.to be_falsey }
    end

    context "when output is different" do
      let(:other_output) { output + "\n" }
      it { is_expected.to be_falsey }
    end

    context "when logging is different" do
      let(:other_logging) { "foo" }
      it { is_expected.to be_falsey }
    end

    context "when failure? is different" do
      let(:other_failure) { !failure }
      it { is_expected.to be_falsey }
    end
  end
end
