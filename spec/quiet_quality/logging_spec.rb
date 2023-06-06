RSpec.describe QuietQuality::Logging do
  let(:including_class) do
    Class.new do
      include QuietQuality::Logging
    end
  end

  subject(:logging_instance) { including_class.new }

  describe "#warn" do
    it "calls the central logger" do
      logging_instance.warn("some text", data: {some: "data"})
      expect(QuietQuality.logger).to have_received(:warn).with("some text", data: {some: "data"})
    end
  end

  describe "#info" do
    it "calls the central logger" do
      logging_instance.info("some text", data: {some: "data"})
      expect(QuietQuality.logger).to have_received(:info).with("some text", data: {some: "data"})
    end
  end

  describe "#debug" do
    it "calls the central logger" do
      logging_instance.debug("some text", data: {some: "data"})
      expect(QuietQuality.logger).to have_received(:debug).with("some text", data: {some: "data"})
    end
  end
end
