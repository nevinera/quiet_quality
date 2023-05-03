RSpec.describe QuietQuality::Annotators do
  describe ".annotate!" do
    let(:annotator) { :github_stdout }
    let(:limit) { nil }
    let(:messages) { generate_messages(10) }
    subject(:annotate!) { described_class.annotate!(annotator: annotator, messages: messages, limit: limit) }

    context "for an unrecognized annotator type" do
      let(:annotator) { :false_annotator }

      it "raises an UnrecognizedAnnotator" do
        expect { annotate! }.to raise_error(QuietQuality::Annotators::Unrecognized)
      end
    end

    context "when the limit isn't set" do
    end

    context "when the limit is larger than the message count" do
    end

    context "when the limit is smaller than the message count" do
    end
  end
end
