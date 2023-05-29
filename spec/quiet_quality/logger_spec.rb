RSpec.describe QuietQuality::Logger do
  let(:level) { nil }
  let(:logging) { QuietQuality::Config::Logging.new(level: level) }
  let(:stream) { instance_double(IO, puts: nil) }
  subject(:logger) { described_class.new(stream: stream, logging: logging) }

  describe "#puts" do
    context "when logging.quiet?" do
      let(:level) { QuietQuality::Config::Logging::QUIET }

      it "does not write the message to the stream" do
        logger.puts("fake message")
        expect(stream).not_to have_received(:puts)
      end
    end

    context "when logging is normal" do
      before { expect(logging).not_to be_quiet }

      it "writes the message to the stream" do
        logger.puts("fake message")
        expect(stream).to have_received(:puts).with("fake message")
      end
    end
  end
end
