RSpec.describe QuietQuality::Tools::Rspec::Parser do
  subject(:parser) { described_class.new(text, tool_options: {}) }

  describe "#messages" do
    let(:text) { fixture_content("tools", "rspec", "no-failures.json") }
    subject(:messages) { parser.messages }

    it "is memoized" do
      first_messages = parser.messages
      expect(parser.messages.object_id).to eq(first_messages.object_id)
    end

    context "when there are no offenses" do
      let(:text) { fixture_content("tools", "rspec", "no-failures.json") }
      it { is_expected.to be_a(QuietQuality::Messages) }
      it { is_expected.to be_empty }
    end

    context "when there are some offenses" do
      let(:text) { fixture_content("tools", "rspec", "failures.json") }
      it { is_expected.to be_a(QuietQuality::Messages) }
      it { is_expected.not_to be_empty }

      it "has the expected offenses in it" do
        expect(messages.count).to eq(2)
        expect(messages.map(&:start_line)).to contain_exactly(73, 54)
      end

      it "properly populates the messages when there is an exception present" do
        m = messages.detect { |msg| msg.start_line == 54 }
        expect(m.path).to eq("spec/quiet_quality/tools/standardrb/runner_spec.rb")
        expect(m.start_line).to eq(54)
        expect(m.rule).to eq("RSpec::Expectations::ExpectationNotMetError")
        expect(m.body).to eq(<<~MESSAGE.strip)
          (Open3).capture3(*(any args))
              expected: 1 time with any arguments
              received: 0 times with any arguments
        MESSAGE
      end

      it "properly populates the message when no exception is present" do
        m = messages.detect { |msg| msg.start_line == 73 }
        expect(m.path).to eq("spec/quiet_quality/tools/standardrb/runner_spec.rb")
        expect(m.start_line).to eq(73)
        expect(m.rule).to eq("Failed Example")
        expect(m.body).to eq("is expected to eq \"wrong fake output\"")
        expect(m.tool_name).to eq(:rspec)
      end
    end

    context "when simplecov dumps its non-json results output into the stream" do
      let(:text) { fixture_content("tools", "rspec", "no-failures.with-simplecov.json") }
      it { is_expected.to be_a(QuietQuality::Messages) }
      it { is_expected.to be_empty }
    end

    context "when simplecov dumps *updated* non-json results output into the stream" do
      let(:text) { fixture_content("tools", "rspec", "no-failures.updated-simplecov.json") }
      it { is_expected.to be_a(QuietQuality::Messages) }
      it { is_expected.to be_empty }
    end

    context "when simplecov dumps multiple filename encoding problems into the stream" do
      let(:text) { fixture_content("tools", "rspec", "no-failures.with-simplecov-encoding-errors.json") }
      it { is_expected.to be_a(QuietQuality::Messages) }
      it { is_expected.to be_empty }
    end

    context "when there are errors outside of examples" do
      let(:text) { fixture_content("tools", "rspec", "errors-outside-of-examples.json") }

      it "raises an Rspec::Error" do
        expect { messages }.to raise_error(
          QuietQuality::Tools::Rspec::Error,
          "Rspec encountered 2 errors outside of examples"
        )
        expect_warn "RSpec errors:"
        expect_warn a_string_matching(/An error occurred while loading/)
        expect_warn "No examples found."
      end
    end
  end
end
