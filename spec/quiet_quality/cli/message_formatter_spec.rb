RSpec.describe QuietQuality::Cli::MessageFormatter do
  let(:message_format) { "foo" }
  subject(:message_formatter) { described_class.new(message_format: message_format) }

  describe "#format" do
    let(:message) do
      generate_message(
        tool_name: "fake_tool",
        path: "path/to/the/file.rb",
        start_line: 5,
        stop_line: stop_line,
        level: "Moderate",
        rule: "FakeRule",
        body: "This is a message"
      )
    end
    let(:stop_line) { 7 }

    subject(:formatted) { message_formatter.format(message) }

    def self.it_formats_with(fmt, as:)
      context "given a format string of '#{fmt}'" do
        let(:message_format) { fmt }
        if as.is_a?(Regexp)
          it { is_expected.to match(as) }
        else
          it { is_expected.to eq(as) }
        end
      end
    end

    it_formats_with "foo", as: "foo"
    it_formats_with "%lered15tool", as: "\e[31mfake_tool      \e[0m"
    it_formats_with "%blue12loc", as: "\e[94mpath/to/the…\e[0m"
    it_formats_with "%rbgreen5level", as: "\e[32m…rate\e[0m"
    it_formats_with "%mblue8path", as: "\e[94mpath….rb\e[0m"
    it_formats_with "%cyan10lines", as: "\e[96m5-7       \e[0m"
    it_formats_with "%none-14rule", as: "FakeRule"
    it_formats_with "%0body", as: "This is a message"
    it_formats_with "%r15level", as: "       Moderate"

    context "when the start_line matches the stop_line" do
      let(:stop_line) { 5 }
      it_formats_with "%0level | %-4lines", as: "Moderate | 5"
    end
  end
end
