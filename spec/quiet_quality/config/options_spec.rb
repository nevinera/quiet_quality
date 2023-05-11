RSpec.describe QuietQuality::Config::Options do
  subject(:options) { described_class.new }

  describe "#comparison_branch" do
    subject(:comparison_branch) { options.comparison_branch }

    context "when not set" do
      it { is_expected.to be_nil }
    end

    context "when set" do
      before { options.comparison_branch = "my-branch" }
      it { is_expected.to eq("my-branch") }
    end
  end

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

  describe "#executor" do
    subject(:executor) { options.executor }
    it { is_expected.to eq(QuietQuality::Executors::ConcurrentExecutor) }

    context "when set to 'concurrent'" do
      before { options.executor = "concurrent" }
      it { is_expected.to eq(QuietQuality::Executors::ConcurrentExecutor) }
    end

    context "when set to 'serial'" do
      before { options.executor = "serial" }
      it { is_expected.to eq(QuietQuality::Executors::SerialExecutor) }
    end

    context "when set to 'fake_executor'" do
      it "raises a UsageError" do
        expect { options.executor = "fake_executor" }
          .to raise_error(QuietQuality::Cli::UsageError, /unrecognized executor/i)
      end
    end
  end
end
