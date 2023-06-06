RSpec.describe QuietQuality do
  describe ".logger" do
    subject(:logger) { described_class.logger }
    it { is_expected.to be_a(QuietQuality::Logger) }

    it "is memoized" do
      logger_one = QuietQuality.logger
      logger_two = QuietQuality.logger
      expect(logger_one.object_id).to eq(logger_two.object_id)
    end
  end
end
