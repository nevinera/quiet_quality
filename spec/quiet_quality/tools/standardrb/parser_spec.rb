RSpec.describe QuietQuality::Tools::Standardrb::Parser do
  subject(:parser) { described_class.new(text) }

  describe "#messages" do
    let(:text) { fixture_content("tools", "standardrb", "no-failures.json") }
    subject(:messages) { parser.messages }

    it "is memoized" do
      first_messages = parser.messages
      expect(parser.messages.object_id).to eq(first_messages.object_id)
    end

    context "when there are no offenses" do
      let(:text) { fixture_content("tools", "standardrb", "no-failures.json") }
      it { is_expected.to be_a(QuietQuality::Messages) }
    end

    context "when there are some offenses" do
      let(:text) { fixture_content("tools", "standardrb", "failures.json") }
      it { is_expected.to be_a(QuietQuality::Messages) }
      it { is_expected.not_to be_empty }

      it "has the expected offenses in it" do
        expect(messages.count).to eq(8)
        expect(messages.map(&:start_line)).to contain_exactly(9, 9, 20, 21, 22, 22, 19, 19)
      end

      it "fully populates the messages" do
        expect(messages.first.path).to eq("lib/quiet_quality/tools/standardrb/parser.rb")
        expect(messages.first.body).to match(/of empty method definitions on the next line/)
        expect(messages.first.start_line).to eq(9)
        expect(messages.first.stop_line).to eq(10)
        expect(messages.first.stop_line).to eq(10)
        expect(messages.first.level).to eq("convention")
        expect(messages.first.rule).to eq("Style/EmptyMethod")
      end
    end
  end
end
