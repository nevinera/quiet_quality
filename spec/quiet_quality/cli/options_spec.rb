RSpec.describe QuietQuality::Cli::Options do
  subject(:options) { described_class.new }

  describe "#annotator" do
    subject(:annotator) { options.annotator }
    it { is_expected.to be_nil }

    context "when set to 'github_stdout'" do
      before { options.annotator = "github_stdout" }
      it { is_expected.to eq(QuietQuality::Annotators::GithubStdout) }
    end

    context "when set to 'fake_annotator'" do
      it "raises a UsageError" do
        expect { options.annotator = "fake_annotator" }
          .to raise_error(QuietQuality::Cli::UsageError, /unrecognized annotator/i)
      end
    end
  end
end
