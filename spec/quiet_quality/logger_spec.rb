RSpec.describe QuietQuality::Logger do
  let(:initial_level) { :warn }
  let(:stream) { instance_double(IO, puts: nil, flush: nil) }
  subject(:logger) { described_class.new(level: initial_level, stream: stream) }

  describe "#level" do
    subject(:level) { logger.level }

    def self.it_shows(level, can_show = true)
      it "will display log messages with level #{level}" do
        if can_show
          expect(logger.show?(level)).to be_truthy
        else
          expect(logger.show?(level)).to be_falsey
        end
      end
    end

    context "by default" do
      let(:logger) { described_class.new }
      it { is_expected.to eq(:warn) }
      it_shows(:warn)
      it_shows(:info, false)
      it_shows(:debug, false)

      it "can be increased from warn to info" do
        expect { logger.increase_level! }.to change(logger, :level).from(:warn).to(:info)
      end
    end

    context "after being set to :none" do
      before { logger.level = :none }
      it { is_expected.to eq(:none) }
      it_shows(:warn, false)
      it_shows(:info, false)
      it_shows(:debug, false)

      it "can be increased from none to warn" do
        expect { logger.increase_level! }.to change(logger, :level).from(:none).to(:warn)
      end
    end

    context "after being set to :info" do
      before { logger.level = :info }
      it { is_expected.to eq(:info) }
      it_shows(:warn)
      it_shows(:info)
      it_shows(:debug, false)

      it "can be increased from info to debug" do
        expect { logger.increase_level! }.to change(logger, :level).from(:info).to(:debug)
      end
    end

    context "after being set to :debug" do
      before { logger.level = :debug }
      it { is_expected.to eq(:debug) }
      it_shows(:warn)
      it_shows(:info)
      it_shows(:debug)

      it "can be increased, but it stays as :debug" do
        expect { logger.increase_level! }.not_to change(logger, :level).from(:debug)
      end
    end
  end

  def self.it_logs_nothing
    it "does not log anything" do
      subject
      expect(stream).not_to have_received(:puts)
    end

    context "when data is supplied" do
      let(:data) { {some: "data"} }

      it "does not log anything" do
        subject
        expect(stream).not_to have_received(:puts)
      end
    end
  end

  def self.it_logs(message, data: nil)
    context(data ? "with data supplied" : "without data supplied") do
      let(:data) { data }

      it "logs the expected message" do
        subject
        expect(stream).to have_received(:puts).with(message)
        expect(stream).to have_received(:flush)
      end
    end
  end

  describe "#warn" do
    let(:data) { nil }
    subject(:warn) { logger.warn("some text", data: data) }

    context "when logging level is :none" do
      let(:initial_level) { :none }
      it_logs_nothing
    end

    [:warn, :info, :debug].each do |iterated_level|
      context "when logging level is :#{iterated_level}" do
        let(:initial_level) { iterated_level }
        it_logs("\e[33m[ WARN] some text\e[0m")
        it_logs(<<~LOGS.strip, data: {some: "data"})
          \e[33m[ WARN] some text
          [ WARN] {
          [ WARN]   "some": "data"
          [ WARN] }\e[0m
        LOGS
      end
    end
  end

  describe "#info" do
    let(:data) { nil }
    subject(:info) { logger.info("some text", data: data) }

    [:none, :warn].each do |iterated_level|
      context "when logging level is :#{iterated_level}" do
        let(:initial_level) { iterated_level }
        it_logs_nothing
      end
    end

    [:info, :debug].each do |iterated_level|
      context "when logging level is :#{iterated_level}" do
        let(:initial_level) { iterated_level }
        it_logs("\e[94m[ INFO] some text\e[0m")
        it_logs(<<~LOGS.strip, data: {some: "data"})
          \e[94m[ INFO] some text
          [ INFO] {
          [ INFO]   "some": "data"
          [ INFO] }\e[0m
        LOGS
      end
    end
  end

  describe "#debug" do
    let(:data) { nil }
    subject(:debug) { logger.debug("some text", data: data) }

    [:none, :warn, :info].each do |iterated_level|
      context "when logging level is :#{iterated_level}" do
        let(:initial_level) { iterated_level }
        it_logs_nothing
      end
    end

    context "when logging level is :debug" do
      let(:initial_level) { :debug }
      it_logs("\e[96m[DEBUG] some text\e[0m")
      it_logs(<<~LOGS.strip, data: {some: "data"})
        \e[96m[DEBUG] some text
        [DEBUG] {
        [DEBUG]   "some": "data"
        [DEBUG] }\e[0m
      LOGS
    end
  end
end
