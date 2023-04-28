RSpec.describe QuietQuality::Tools::Standardrb::Runner do
  let(:changed_files) { nil }
  let(:error_stream) { instance_double(IO, write: nil) }
  subject(:runner) { described_class.new(changed_files: changed_files, error_stream: error_stream) }

  let(:out) { "fake output" }
  let(:err) { "fake error" }
  let(:stat) { instance_double(Process::Status, success?: true, exitstatus: 0) }
  before { allow(Open3).to receive(:capture3).and_return([out, err, stat]) }

  describe "#invoke!" do
    subject(:invoke!) { runner.invoke! }

    context "when the standardrb command _fails_" do
      let(:stat) { instance_double(Process::Status, success?: false, exitstatus: 14) }

      it "raises a Standardrb::ExecutionError" do
        expect { invoke! }.to raise_error(QuietQuality::Tools::Standardrb::ExecutionError)
      end
    end

    context "when changed_files is nil" do
      let(:changed_files) { nil }
      it { is_expected.to eq("fake output") }

      it "calls standardrb correctly, with no targets" do
        invoke!
        expect(Open3)
          .to have_received(:capture3)
          .with("standardrb", "-f", "json", "--fail-level", "fatal")
      end
    end

    context "when changed_files is empty" do
      let(:changed_files) { [] }
      it { is_expected.to eq(described_class::NO_FILES_OUTPUT) }

      it "does not call standardrb" do
        invoke!
        expect(Open3).not_to have_received(:capture3)
      end
    end

    context "when changed_files is full" do
      let(:file1) { "foo.js" }
      let(:file2) { "bar.rb" }
      let(:file3) { "baz.rb" }
      let(:changed_files) { [file1, file2, file3] }

      context "but contains no ruby files" do
        let(:file2) { "bar.js" }
        let(:file3) { "baz.ts" }

        it "does not call standardrb" do
          invoke!
          expect(Open3).not_to have_received(:capture3)
        end
      end

      context "and contains some ruby files" do
        it { is_expected.to eq("fake output") }

        it "calls standardrb correctly, with changed and relevant targets" do
          invoke!
          expect(Open3)
            .to have_received(:capture3)
            .with("standardrb", "-f", "json", "--fail-level", "fatal", "bar.rb", "baz.rb")
        end
      end

      context "and contains too many ruby files" do
        before { stub_const("QuietQuality::Tools::Standardrb::Runner::MAX_FILES", 1) }
        it { is_expected.to eq("fake output") }

        it "calls standardrb correctly, with no targets" do
          invoke!
          expect(Open3)
            .to have_received(:capture3)
            .with("standardrb", "-f", "json", "--fail-level", "fatal")
        end
      end
    end
  end
end
