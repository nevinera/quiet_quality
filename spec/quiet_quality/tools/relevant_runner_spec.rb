require_relative "./runner_examples"

RSpec.describe QuietQuality::Tools::RelevantRunner do
  let(:changed_files) { nil }
  let(:file_filter) { /\.rb$/ }
  subject(:runner) { subclass.new(changed_files: changed_files, file_filter: file_filter) }

  context "with an improperly implemented subclass" do
    let(:subclass) { Class.new(described_class) }

    describe "#invoke!" do
      subject(:invoke!) { runner.invoke! }

      it "raises a NoMethodError" do
        expect { invoke! }.to raise_error(NoMethodError)
      end
    end

    describe "#command" do
      subject(:command) { runner.command }

      it "raises a NoMethodError" do
        expect { command }.to raise_error(NoMethodError)
      end
    end

    describe "#relevant_path?" do
      let(:path) { "fake/path" }
      subject(:relevant_path?) { runner.relevant_path?(path) }

      it "raises a NoMethodError" do
        expect { relevant_path? }
          .to raise_error(NoMethodError, /RelevantRunner subclass must.*relevant_path/)
      end
    end

    describe "#base_command" do
      subject(:base_command) { runner.base_command }

      it "raises a NoMethodError" do
        expect { base_command }
          .to raise_error(NoMethodError, /RelevantRunner subclass must.*command.*base_command/)
      end
    end

    describe "#no_files_output" do
      subject(:no_files_output) { runner.no_files_output }

      it "raises a NoMethodError" do
        expect { no_files_output }
          .to raise_error(NoMethodError, /RelevantRunner subclass must.*no_files_output/)
      end
    end
  end

  context "with a properly implemented subclass" do
    let(:subclass) do
      Class.new(described_class) do
        def tool_name
          :fake_tool
        end

        def relevant_path?(path)
          path.include?("foo")
        end

        def base_command
          ["fake", "command"]
        end

        def no_files_output
          "no files"
        end
      end
    end

    describe "#command" do
      subject(:command) { runner.command }

      context "when there are no changes to consider" do
        let(:changed_files) { nil }
        it { is_expected.to eq(["fake", "command"]) }
      end

      context "when there are changes to consider" do
        context "but they are empty" do
          let(:changed_files) { empty_changed_files }
          it { is_expected.to be_nil }
        end

        context "but they contain no files matching the relevance method and file_filter" do
          let(:changed_files) { fully_changed_files("baz.rb", "zum", "zim.rb", "zam") }
          it { is_expected.to be_nil }
        end

        context "and they contain some files that are relevant" do
          let(:changed_files) { fully_changed_files("baz", "foobar.rb", "zim", "foo.rb") }
          it { is_expected.to eq(["fake", "command", "foo.rb", "foobar.rb"]) }
        end
      end
    end

    describe "#invoke!" do
      subject(:invoke!) { runner.invoke! }

      let(:out) { "fake stdout" }
      let(:err) { "fake stderr" }
      let(:stat) { mock_status(0) }
      before { allow(Open3).to receive(:capture3).and_return([out, err, stat]) }

      shared_examples "exposes the successful command output" do
        it { is_expected.to eq(build_success(:fake_tool, out, err)) }

        it "invokes the tool with the command" do
          invoke!
          expect(Open3).to have_received(:capture3).with(*runner.command)
        end
      end

      shared_examples "skips the command and succeeds immediately" do
        it { is_expected.to eq(build_success(:fake_tool, runner.no_files_output)) }

        it "invokes the tool with the command" do
          invoke!
          expect(Open3).not_to have_received(:capture3)
        end
      end

      context "when there are no changes to consider" do
        let(:changed_files) { nil }
        include_examples "exposes the successful command output"
      end

      context "when there are changes to consider" do
        context "but they are empty" do
          let(:changed_files) { empty_changed_files }
          include_examples "skips the command and succeeds immediately"
        end

        context "but they contain no files matching the relevance method and file_filter" do
          let(:changed_files) { fully_changed_files("baz.rb", "zum", "zim.rb", "zam") }
          include_examples "skips the command and succeeds immediately"
        end

        context "and they contain some files that are relevant" do
          let(:changed_files) { fully_changed_files("baz", "foobar.rb", "zim", "foo.rb") }
          include_examples "exposes the successful command output"
        end
      end
    end

    it_behaves_like "a functional RelevantRunner subclass", :fake_tool, {
      runner_class_method: :subclass,
      relevant: "foo.rb",
      irrelevant: "bar.rb",
      filter: /\.rb/,
      base_command: ["fake", "command"]
    }
  end
end
