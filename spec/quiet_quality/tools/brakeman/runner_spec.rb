RSpec.describe QuietQuality::Tools::Brakeman::Runner do
  let(:changed_files) { nil }
  subject(:runner) { described_class.new }

  let(:out) { "fake output" }
  let(:err) { "fake error" }
  let(:stat) { instance_double(Process::Status, success?: true, exitstatus: 0) }
  before { allow(Open3).to receive(:capture3).and_return([out, err, stat]) }

  describe "#invoke!" do
    subject(:invoke!) { runner.invoke! }

    context "when the brakeman command fails" do
      let(:stat) { instance_double(Process::Status, success?: false, exitstatus: 14) }

      it "raises an ExecutionError" do
        expect { invoke! }.to raise_error(QuietQuality::Tools::ExecutionError)
      end
    end

    context "when the brakeman command finds warnings" do
      let(:stat) { instance_double(Process::Status, success?: false, exitstatus: 3) }
      it { is_expected.to eq(build_failure(:brakeman, "fake output", "fake error")) }

      it "calls brakeman correctly" do
        invoke!
        expect(Open3).to have_received(:capture3).with("brakeman", "-f", "json")
      end
    end

    context "when the brakeman command finds no problems" do
      let(:stat) { instance_double(Process::Status, success?: true, exitstatus: 0) }
      it { is_expected.to eq(build_success(:brakeman, "fake output", "fake error")) }

      it "calls brakeman correctly" do
        invoke!
        expect(Open3).to have_received(:capture3).with("brakeman", "-f", "json")
      end
    end
  end
end
