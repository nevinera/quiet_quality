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

    let(:remote_double) { instance_double(Git::Remote, url: "remote_url") }
    let(:git_double) { instance_double(Git::Base, remote: remote_double, merge_base: [expected_base]) }
    let(:expected_base) { instance_double(Git::Object::Commit, sha: "abcd1234") }

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

      it { is_expected.to eq("abcd1234") }
    end
  end

  context "on the fixture repository" do
    let(:repo_path) { tmp_path("repo") }
    subject(:fixture_repo) { described_class.new(repo_path) }

    # Can't test default_branch unfortunately - it needs to reach out to the upstream repository
    # to _ask_, which isn't really appropriate in a test suite. But I think it's simple enough
    # to not worry about - it does actually return a string branch name.

    describe "#comparison_base" do
      subject(:comparison_base) { fixture_repo.comparison_base(sha: sha, comparison_branch: branch) }
      let(:sha) { "HEAD" }
      let(:branch) { "main" }
      it { is_expected.to start_with("d1e4d54") }
    end
  end
end
