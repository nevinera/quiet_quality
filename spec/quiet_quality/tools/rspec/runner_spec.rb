RSpec.describe QuietQuality::Tools::Rspec::Runner do
  let(:changed_files) { nil }
  subject(:runner) { described_class.new(changed_files: changed_files) }

  let(:out) { "fake output" }
  let(:err) { "fake error" }
  let(:stat) { instance_double(Process::Status, success?: true, exitstatus: 0) }
  before { allow(Open3).to receive(:capture3).and_return([out, err, stat]) }

  describe "#invoke!" do
    subject(:invoke!) { runner.invoke! }

    context "when the rspec command fails" do
      let(:stat) { instance_double(Process::Status, success?: false, exitstatus: 14) }

      it "raises an Rspec::ExecutionError" do
        expect { invoke! }.to raise_error(QuietQuality::Tools::Rspec::ExecutionError)
      end
    end

    context "when changed_files is nil" do
      let(:changed_files) { nil }
      it { is_expected.to eq(build_success("fake output", "fake error")) }

      it "calls rspec with no targets" do
        invoke!
        expect(Open3)
          .to have_received(:capture3)
          .with("rspec", "--failure-exit-code", "0", "-f", "json")
      end
    end

    context "when changed_files is empty" do
      let(:changed_files) { [] }
      it { is_expected.to eq(build_success(described_class::NO_FILES_OUTPUT)) }

      it "does not call rspec" do
        expect(Open3).not_to have_received(:capture3)
      end
    end

    context "when changed_files is full" do
      context "but contains no spec files" do
        let(:changed_files) { ["foo_spec.ts", "bar.rb", "baz_spec.rb.bak"] }
        it { is_expected.to eq(build_success(described_class::NO_FILES_OUTPUT)) }

        it "does not call rspec" do
          expect(Open3).not_to have_received(:capture3)
        end
      end

      context "and contains some spec files" do
        let(:changed_files) { ["foo_spec.ts", "bar_spec.rb", "baz_spec.rb.bak", "a/alpha_spec.rb"] }
        it { is_expected.to eq(build_success("fake output", "fake error")) }

        it "calls rspec with no targets" do
          invoke!
          expect(Open3)
            .to have_received(:capture3)
            .with("rspec", "--failure-exit-code", "0", "-f", "json", "a/alpha_spec.rb", "bar_spec.rb")
        end
      end
    end
  end
end
