require "ostruct"

RSpec.describe QuietQuality::VersionControlSystems::Git do
  describe ".default_branch" do
    let(:remote) { "https://some.remote.git.url" }
    subject(:default_branch) { described_class.default_branch(remote: remote) }

    it "delegates to the Git api" do
      expect(Git).to receive(:default_branch).with(remote)
      default_branch
    end
  end

  context "instance methods" do
    let(:path) { "/path/to/git/repo" }
    let(:instance) { described_class.new(path) }

    let(:git_double) {
      instance_double(Git::Base, remote: OpenStruct.new(url: "remote_url"), merge_base: "expected_base")
    }

    before do
      expect(Git).to receive(:open).with(path).and_return(git_double)
    end

    describe "#default_branch" do
      subject(:default_branch) { instance.default_branch }

      it "delegates to the Git api" do
        expect(Git).to receive(:default_branch).with("remote_url")
        default_branch
      end
    end

    describe "#comparison_base" do
      let(:sha) { "ABCDEF123456" }
      let(:branch) { "default_branch" }
      subject(:comparison_base) {
        instance.comparison_base(sha: sha, comparison_branch: branch)
      }

      it "delegates to the Git api" do
        comparison_base
        expect(git_double).to have_received(:merge_base).with(branch, sha)
      end
    end
  end
end
