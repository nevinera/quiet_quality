RSpec.describe QuietQuality::Tools::HamlLint::Parser do
  subject(:parser) { described_class.new(text) }

  describe "#messages" do
    let(:text) { fixture_content("tools", "haml_lint", "no-failures.json") }
    subject(:messages) { parser.messages }

    it "is memoized" do
      first_messages = parser.messages
      expect(parser.messages.object_id).to eq(first_messages.object_id)
    end

    context "when there are no offenses" do
      let(:text) { fixture_content("tools", "haml_lint", "no-failures.json") }
      it { is_expected.to be_a(QuietQuality::Messages) }
      it { is_expected.to be_empty }
    end

    context "when there are some offenses" do
      let(:text) { fixture_content("tools", "haml_lint", "failures.json") }
      it { is_expected.to be_a(QuietQuality::Messages) }
      it { is_expected.not_to be_empty }

      it "has the expected offenses in it" do
        expect(messages.count).to eq(3)
        expect(messages.map(&:start_line)).to contain_exactly(1, 3, 3)
      end

      it "fully populates the messages" do
        expect(messages.first.path).to eq("tmp/good.haml")
        expect(messages.first.body).to eq("`%div.foo` can be written as `.foo` since `%div` is implicit")
        expect(messages.first.start_line).to eq(1)
        expect(messages.first.level).to eq("warning")
        expect(messages.first.rule).to eq("ImplicitDiv")
        expect(messages.first.tool_name).to eq(:haml_lint)
      end
    end
  end
end
