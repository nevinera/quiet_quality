RSpec.describe QuietQuality::ToolOptions do
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

  describe "constants for tools" do
    shared_examples "exposes the expected constants for" do |tool_name, expected_namespace|
      context "for #{tool_name}" do
        let(:tool) { tool_name }

        it "exposes the right constants" do
          expect(tool_options.tool_namespace).to eq(expected_namespace)
          expect(tool_options.runner_class).to eq(expected_namespace::Runner)
          expect(tool_options.parser_class).to eq(expected_namespace::Parser)
        end
      end
    end

    include_examples "exposes the expected constants for", :rspec, QuietQuality::Tools::Rspec
    include_examples "exposes the expected constants for", :rubocop, QuietQuality::Tools::Rubocop
    include_examples "exposes the expected constants for", :standardrb, QuietQuality::Tools::Standardrb
  end
end
