RSpec.describe QuietQuality::Tools::MarkdownLint::Parser do
  subject(:parser) { described_class.new(text) }

  describe "#messages" do
    let(:text) { fixture_content("tools", "markdown_lint", "no-failures.json") }
    subject(:messages) { parser.messages }

    it "is memoized" do
      first_messages = parser.messages
      expect(parser.messages.object_id).to eq(first_messages.object_id)
    end

    context "when there are no offenses" do
      let(:text) { fixture_content("tools", "markdown_lint", "no-failures.json") }
      it { is_expected.to be_a(QuietQuality::Messages) }
      it { is_expected.to be_empty }
    end

    context "when there are some offenses" do
      let(:text) { fixture_content("tools", "markdown_lint", "failures.json") }
      it { is_expected.to be_a(QuietQuality::Messages) }
      it { is_expected.not_to be_empty }

      it "has the expected offenses in it" do
        expect(messages.count).to eq(5)
        expect(messages.map(&:start_line)).to contain_exactly(23, 1, 1, 3, 1)
      end

      it "fully populates the messages" do
        m = messages.detect { |m| m.path == "README.md" }
        expect(m.start_line).to eq(23)
        expect(m.stop_line).to eq(23)
        expect(m.rule).to eq("Line length")
        expect(m.body).to eq("https://github.com/markdownlint/markdownlint/blob/master/docs/RULES.md#md013---line-length")
        expect(m.tool_name).to eq(:markdown_lint)
      end
    end
  end
end
