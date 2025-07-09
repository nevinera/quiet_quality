RSpec.describe QuietQuality::Executors::Pipeline do
  let(:limit_targets?) { true }
  let(:filter_messages?) { true }
  let(:command_override) { ["my", "command"] }
  let(:exec_override) { ["my", "exec"] }
  let(:tool_name) { :rspec }
  let(:tool_opts) { tool_options(tool_name, limit_targets: limit_targets?, filter_messages: filter_messages?, file_filter: ".*", command: command_override, exec_command: exec_override) }

  let(:foo_file) { QuietQuality::ChangedFile.new(path: "path/foo.rb", lines: [1, 2, 3, 5, 10]) }
  let(:bar_file) { QuietQuality::ChangedFile.new(path: "path/bar.rb", lines: [5, 6, 7, 14, 15]) }
  let(:bug_file) { QuietQuality::ChangedFile.new(path: "path/bug.rb", lines: :all) }
  let(:changed_files) { QuietQuality::ChangedFiles.new([foo_file, bar_file, bug_file]) }

  let(:runner_outcome) { build_failure(tool_name, "fake output", "fake logging") }
  let(:runner_class) { QuietQuality::Tools::Rspec::Runner }
  let(:runner) { instance_double(runner_class, invoke!: runner_outcome, tool_name: :rspec, command: ["foo", "bar"]) }
  before { allow(runner_class).to receive(:new).and_return(runner) }

  let(:other_messages) { generate_messages(4, path: "path/other.rb") }
  let(:foo_message) { generate_message(path: "path/foo.rb", start_line: 3, stop_line: 7, body: "foo text") }
  let(:bar_message) { generate_message(path: "path/bar.rb", start_line: 8, stop_line: 12, body: "bar text") }
  let(:parsed_messages) { QuietQuality::Messages.new(other_messages + [foo_message, bar_message]) }
  let(:parser) { instance_double(QuietQuality::Tools::Rspec::Parser, messages: parsed_messages) }
  before { allow(QuietQuality::Tools::Rspec::Parser).to receive(:new).and_return(parser) }

  subject(:pipeline) { described_class.new(tool_options: tool_opts, changed_files: changed_files) }

  describe "#tool_name" do
    subject { pipeline.tool_name }
    it { is_expected.to eq(:rspec) }
  end

  describe "#outcome" do
    subject(:outcome) { pipeline.outcome }

    it "logs the runner command" do
      outcome
      expect_info("Runner rspec command: `foo bar`")
      expect_debug("Full command for rspec", data: ["foo", "bar"])
    end

    context "when targets are to be limited" do
      let(:limit_targets?) { true }

      it "sets up the runner correctly" do
        outcome
        expect(runner_class).to have_received(:new).with(
          changed_files: changed_files,
          file_filter: /.*/,
          command_override: command_override,
          exec_override: exec_override
        )
      end
    end

    context "when targets are not to be limited" do
      let(:limit_targets?) { false }

      it "sets up the runner correctly" do
        outcome
        expect(runner_class).to have_received(:new).with(
          changed_files: nil,
          file_filter: /.*/,
          command_override: command_override,
          exec_override: exec_override
        )
      end
    end

    context "when the runner is skipping" do
      before { allow(runner).to receive(:command).and_return(nil) }

      it "logs the empty command" do
        outcome
        expect_info("Runner rspec command: (skipped)")
        expect_debug("Full command for rspec", data: nil)
      end
    end

    shared_examples "it matches the runner outcome, failure status aside" do
      it "matches the runner outcome, aside from the failure status" do
        expect(outcome.output).to eq(runner_outcome.output)
        expect(outcome.logging).to eq(runner_outcome.logging)
        expect(outcome.tool).to eq(runner_outcome.tool)
      end
    end

    context "when there are messages from the tool" do
      let(:parsed_messages) { QuietQuality::Messages.new(other_messages + [foo_message, bar_message]) }

      include_examples "it matches the runner outcome, failure status aside"
      it { is_expected.to be_failure }

      context "but they are all filtered" do
        let(:parsed_messages) { QuietQuality::Messages.new(other_messages) }
        include_examples "it matches the runner outcome, failure status aside"
        it { is_expected.not_to be_failure }
      end
    end

    context "when there are no messages from the tool" do
      let(:parsed_messages) { empty_messages }
      include_examples "it matches the runner outcome, failure status aside"
      it { is_expected.not_to be_failure }
    end
  end

  describe "#failure?" do
    subject(:failure?) { pipeline.failure? }

    context "when there are messages from the tool" do
      let(:parsed_messages) { QuietQuality::Messages.new(other_messages + [foo_message, bar_message]) }
      it { is_expected.to be_truthy }

      context "but they are all filtered" do
        let(:parsed_messages) { QuietQuality::Messages.new(other_messages) }
        it { is_expected.to be_falsey }
      end
    end

    context "when there are no messages from the tool" do
      let(:parsed_messages) { empty_messages }
      it { is_expected.to be_falsey }
    end
  end

  describe "#messages" do
    subject(:messages) { pipeline.messages }

    context "with no changed_files supplied" do
      let(:changed_files) { nil }
      it { is_expected.to be_a(QuietQuality::Messages) }
      it { is_expected.to eq(parsed_messages) }

      it "doesn't log the filtering" do
        messages
        expect_not_logged(:info, /filtered from/)
        expect_not_logged(:info, /positioned/)
      end
    end

    context "with filter_messages disabled" do
      let(:filter_messages?) { false }
      it { is_expected.to be_a(QuietQuality::Messages) }
      it { is_expected.to eq(parsed_messages) }

      it "locates the foo message properly, but not the others" do
        messages.each do |msg|
          if msg.body == "foo text"
            expect(msg.annotated_line).to eq(5)
          else
            expect(msg.annotated_line).to be_nil
          end
        end
      end

      it "doesn't log the filtering, but does log repositioning" do
        messages
        expect_not_logged(:info, /filtered from/)
        expect_info("Messages for rspec positioned into the diff for annotation purposes")
      end
    end

    context "with filter_messages enabled" do
      let(:filter_messages?) { true }
      it { is_expected.to be_a(QuietQuality::Messages) }

      it "includes only foo_message" do
        expect(messages.count).to eq(1)
        expect(messages.first.body).to eq("foo text")
      end

      it "locates those messages properly" do
        expect(messages.first.annotated_line).to eq(5)
      end

      it "logs the filtering properly" do
        messages
        expect_info("Messages for rspec filtered from 6 to 1")
        expect_info("Messages for rspec positioned into the diff for annotation purposes")
      end
    end

    it "passes the expected data to the parser" do
      messages
      expect(QuietQuality::Tools::Rspec::Parser).to have_received(:new)
        .with(runner_outcome, tool_options: tool_opts)
    end
  end
end
