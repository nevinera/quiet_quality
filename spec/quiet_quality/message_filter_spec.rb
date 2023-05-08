RSpec.describe QuietQuality::MessageFilter do
  let(:foo_file) { QuietQuality::ChangedFile.new(path: "path/foo.rb", lines: [1, 2, 3, 5, 10]) }
  let(:bar_file) { QuietQuality::ChangedFile.new(path: "path/bar.rb", lines: [5, 6, 7, 14, 15]) }
  let(:bug_file) { QuietQuality::ChangedFile.new(path: "path/bug.rb", lines: :all) }
  let(:changed_files) { QuietQuality::ChangedFiles.new([foo_file, bar_file, bug_file]) }

  subject(:message_filter) { described_class.new(changed_files: changed_files) }

  describe "#relevant?" do
    subject(:relevant?) { message_filter.relevant?(message) }

    context "when the message isn't in a changed file" do
      let(:message) { generate_message(path: "path/nope.rb", start_line: 1) }
      it { is_expected.to be_falsey }
    end

    context "when the message is in a file that was entirely changed" do
      let(:message) { generate_message(path: "path/bug.rb", start_line: 999_999) }
      it { is_expected.to be_truthy }
    end

    context "when the message is on a single line" do
      let(:message) { generate_message(path: "path/bar.rb", start_line: line, stop_line: line) }

      context "when the message is on a changed line" do
        let(:line) { 6 }
        it { is_expected.to be_truthy }
      end

      context "when the mssage is on an unchanged line" do
        let(:line) { 9 }
        it { is_expected.to be_falsey }
      end
    end

    context "when the message spans multiple lines" do
      let(:message) { generate_message(path: "path/bar.rb", start_line: line, stop_line: line + 2) }

      context "when the message spans no changed lines" do
        let(:line) { 8 }
        it { is_expected.to be_falsey }
      end

      context "when the message crosses a changed line" do
        let(:line) { 13 }
        it { is_expected.to be_truthy }
      end
    end
  end

  describe "#filter" do
    let(:msg_a) { generate_message(path: "path/nope.rb", start_line: 1) }
    let(:msg_b) { generate_message(path: "path/bug.rb", start_line: 999_999) }
    let(:msg_c) { generate_message(path: "path/bar.rb", start_line: 6, stop_line: 6) }
    let(:msg_d) { generate_message(path: "path/bar.rb", start_line: 9, stop_line: 9) }
    let(:msg_e) { generate_message(path: "path/bar.rb", start_line: 8, stop_line: 10) }
    let(:msg_f) { generate_message(path: "path/bar.rb", start_line: 13, stop_line: 15) }
    let(:messages) { [msg_a, msg_b, msg_c, msg_d, msg_e, msg_f] }
    subject(:filter) { message_filter.filter(messages) }

    it { is_expected.to be_a(QuietQuality::Messages) }
    it { is_expected.to contain_exactly(msg_b, msg_c, msg_f) }
  end
end
