RSpec.describe QuietQuality::Cli::ToolOptions do
  let(:tool) { "foo" }
  subject(:tool_options) { described_class.new(tool) }

  describe "#tool_name" do
    subject(:tool_name) { tool_options.tool_name }
    it { is_expected.to eq(:foo) }
  end

  describe "#limit_targets?" do
    subject(:limit_targets?) { tool_options.limit_targets? }
    it { is_expected.to be_truthy }

    context "when it is set to false" do
      before { tool_options.limit_targets = false }
      it { is_expected.to be_falsey }
    end
  end

  describe "#filter_messages?" do
    subject(:filter_messages?) { tool_options.filter_messages? }
    it { is_expected.to be_truthy }

    context "when it is set to false" do
      before { tool_options.filter_messages = false }
      it { is_expected.to be_falsey }
    end
  end
end
