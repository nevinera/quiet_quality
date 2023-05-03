RSpec.describe QuietQuality::Annotators do
  describe ".annotate!" do
    let(:limit) { nil }
    let(:messages) { generate_messages(10) }
    subject(:annotate!) { described_class.annotate!(annotator: annotator, messages: messages, limit: limit) }

    context "for an unrecognized annotator type" do
      let(:annotator) { :false_annotator }

      it "raises an UnrecognizedAnnotator" do
        expect { annotate! }.to raise_error(QuietQuality::Annotators::Unrecognized)
      end
    end

    context "for the :github_stdout annotator" do
      let(:annotator) { :github_stdout }
      let(:fake_annotator) { instance_double(QuietQuality::Annotators::GithubStdout, annotate!: nil) }
      before { allow(QuietQuality::Annotators::GithubStdout).to receive(:new).and_return(fake_annotator) }

      context "when the limit isn't set" do
        let(:limit) { nil }

        it "invokes the annotator correctly" do
          annotate!
          expect(fake_annotator).to have_received(:annotate!).with(messages)
        end
      end

      context "when the limit is larger than the message count" do
        let(:limit) { 15 }

        it "invokes the annotator correctly" do
          annotate!
          expect(fake_annotator).to have_received(:annotate!).with(messages)
        end
      end

      context "when the limit is smaller than the message count" do
        let(:limit) { 3 }

        it "invokes the annotator correctly" do
          annotate!
          expect(fake_annotator).to have_received(:annotate!).with(messages.first(3))
        end
      end
    end
  end
end
