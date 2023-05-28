require_relative "./runner_examples"

RSpec.describe QuietQuality::Tools::BaseRunner do
  let(:changed_files) { instance_double(QuietQuality::ChangedFiles) }
  let(:file_filter) { instance_double(Regexp) }
  subject(:runner) { subclass.new(changed_files: changed_files, file_filter: file_filter) }

  context "with an improperly implemented subclass" do
    let(:subclass) { Class.new(described_class) }

    describe "#invoke!" do
      subject(:invoke!) { runner.invoke! }

      it "raises a NoMethodError" do
        expect { invoke! }.to raise_error(NoMethodError)
      end
    end

    describe "#tool_name" do
      subject(:tool_name) { runner.tool_name }

      it "raises a NoMethodError" do
        expect { tool_name }.to raise_error(NoMethodError, /must implement.*tool_name/i)
      end
    end

    describe "#command" do
      subject(:command) { runner.command }

      it "raises a NoMethodError" do
        expect { command }.to raise_error(NoMethodError, /must implement.*command/i)
      end
    end
  end

  context "with a properly implemented subclass" do
    let(:subclass) do
      Class.new(described_class) do
        def tool_name
          :fake_tool
        end

        def command
          ["fake", "command"]
        end
      end
    end

    describe "#success_status?" do
      subject(:success_status?) { runner.success_status?(stat) }

      context "for an exit status of 0" do
        let(:stat) { mock_status(0) }
        it { is_expected.to be_truthy }
      end

      context "for an exit status of 1" do
        let(:stat) { mock_status(1) }
        it { is_expected.to be_falsey }
      end

      context "for an exit status of 99" do
        let(:stat) { mock_status(99) }
        it { is_expected.to be_falsey }
      end
    end

    describe "#failure_status?" do
      subject(:failure_status) { runner.failure_status?(stat) }

      context "for an exit status of 0" do
        let(:stat) { mock_status(0) }
        it { is_expected.to be_falsey }
      end

      context "for an exit status of 1" do
        let(:stat) { mock_status(1) }
        it { is_expected.to be_truthy }
      end

      context "for an exit status of 99" do
        let(:stat) { mock_status(99) }
        it { is_expected.to be_falsey }
      end
    end

    describe "#invoke!" do
      subject(:invoke!) { runner.invoke! }

      let(:out) { "fake stdout" }
      let(:err) { "fake stderr" }
      before { allow(Open3).to receive(:capture3).and_return([out, err, stat]) }

      context "when successful" do
        let(:stat) { mock_status(0) }
        it { is_expected.to eq(build_outcome(tool: :fake_tool, output: out, logging: err, failure: false)) }

        it "invokes the command correctly" do
          invoke!
          expect(Open3).to have_received(:capture3).with("fake", "command")
        end
      end

      context "when failures found" do
        let(:stat) { mock_status(1) }
        it { is_expected.to eq(build_outcome(tool: :fake_tool, output: out, logging: err, failure: true)) }

        it "invokes the command correctly" do
          invoke!
          expect(Open3).to have_received(:capture3).with("fake", "command")
        end
      end

      context "when an unexpected status is encountered" do
        let(:stat) { mock_status(99) }

        it "raises an ExecutionError" do
          expect { invoke! }.to raise_error(
            QuietQuality::Tools::ExecutionError,
            /Execution of fake_tool failed with 99/
          )
        end
      end
    end

    it_behaves_like "a functional BaseRunner subclass", :fake_tool, runner_class_method: :subclass
  end
end
