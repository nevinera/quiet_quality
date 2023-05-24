RSpec.describe QuietQuality::Executors::Pipeline do
  let(:limit_targets?) { true }
  let(:filter_messages?) { true }
  let(:tool_name) { :rspec }
  let(:tool_opts) { tool_options(tool_name, limit_targets: limit_targets?, filter_messages: filter_messages?) }

  let(:foo_file) { QuietQuality::ChangedFile.new(path: "path/foo.rb", lines: [1, 2, 3, 5, 10]) }
  let(:bar_file) { QuietQuality::ChangedFile.new(path: "path/bar.rb", lines: [5, 6, 7, 14, 15]) }
  let(:bug_file) { QuietQuality::ChangedFile.new(path: "path/bug.rb", lines: :all) }
  let(:changed_files) { QuietQuality::ChangedFiles.new([foo_file, bar_file, bug_file]) }

  let(:runner_outcome) { build_failure(tool_name, "fake output", "fake logging") }
  let(:runner) { instance_double(QuietQuality::Tools::Rspec::Runner, invoke!: runner_outcome) }
  before { allow(QuietQuality::Tools::Rspec::Runner).to receive(:new).and_return(runner) }

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
    end
  end
end
