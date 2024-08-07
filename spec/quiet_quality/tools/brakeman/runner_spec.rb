require_relative "../runner_examples"

RSpec.describe QuietQuality::Tools::Brakeman::Runner do
  let(:changed_files) { nil }
  subject(:runner) { described_class.new }

  describe "#tool_name" do
    subject(:tool_name) { runner.tool_name }
    it { is_expected.to eq(:brakeman) }
  end

  describe "#command" do
    subject(:command) { runner.command }
    it { is_expected.to eq(["brakeman", "-f", "json"]) }

    context "with a command_override supplied" do
      let(:runner) { described_class.new(command_override: ["brakeman", "--foo"]) }
      it { is_expected.to eq(["brakeman", "--foo"]) }
    end
  end

  describe "#exec_command" do
    subject(:exec_command) { runner.exec_command }
    it { is_expected.to eq(["brakeman"]) }

    context "with an exec_override supplied" do
      let(:runner) { described_class.new(exec_override: ["brakeman", "--foo"]) }
      it { is_expected.to eq(["brakeman", "--foo"]) }
    end
  end

  it_behaves_like "a functional BaseRunner subclass", :brakeman, failure: (3..8) do
    it "calls brakeman correctly" do
      runner.invoke!
      expect(Open3).to have_received(:capture3).with("brakeman", "-f", "json")
    end
  end
end
