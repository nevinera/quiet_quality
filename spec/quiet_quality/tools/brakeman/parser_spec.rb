RSpec.describe QuietQuality::Tools::Brakeman::Parser do
  subject(:parser) { described_class.new(text) }

  describe "#messages" do
    let(:text) { fixture_content("tools", "brakeman", "no-failures.json") }
    subject(:messages) { parser.messages }

    it "is memoized" do
      first_messages = parser.messages
      expect(parser.messages.object_id).to eq(first_messages.object_id)
    end

    context "when there are no offenses" do
      let(:text) { fixture_content("tools", "brakeman", "no-failures.json") }
      it { is_expected.to be_a(QuietQuality::Messages) }
      it { is_expected.to be_empty }
    end

    context "when there are some offenses" do
      let(:text) { fixture_content("tools", "brakeman", "failures.json") }
      it { is_expected.to be_a(QuietQuality::Messages) }
      it { is_expected.not_to be_empty }

      it "has the expected offenses in it" do
        expect(messages.count).to eq(2)
        expect(messages.map(&:start_line)).to contain_exactly(3, 11)
      end

      it "properly populates the messages" do
        m = messages.detect { |msg| msg.start_line == 3 }
        expect(m.path).to eq("app/controllers/articles_controller.rb")
        expect(m.body).to eq("Possible SQL injection")
        expect(m.start_line).to eq(3)
        expect(m.level).to eq("High")
        expect(m.rule).to eq("SQL Injection")
        expect(m.tool_name).to eq(:brakeman)
      end
    end

    context "when there are errors" do
      let(:text) { fixture_content("tools", "brakeman", "errors.json") }

      it "raises a ParsingError and logs the errors" do
        expect { messages }.to raise_error(
          QuietQuality::Tools::ParsingError,
          /Found 2 errors/
        )
        expect_warn "Brakeman errors:"
        expect_warn "    Something went wrong"
        expect_warn "    Something else too"
      end
    end
  end
end
