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
    let(:git_repo_path) { "tmp/repo" }
    let(:base_sha) { "main" }

    let(:instance) { described_class.new(git_repo_path) }

    describe "#changed_files" do
      let(:base_params) { {base: base_sha} }
      let(:params) { base_params }
      subject(:changed_files) { instance.changed_files(**params) }

      context "committed_changes" do
        let(:params) { base_params.merge({include_uncommitted: false, include_untracked: false}) }
        it { should be_a QuietQuality::ChangedFiles }

        it "should have the correct files" do
          expect(changed_files.files.map(&:path)).to include("bar/baz/h.txt", "foo/f.txt", "foo/g/g.txt")
        end

        it "should have the correct line numbers" do
          expect(changed_files.files.map(&:lines)).to include([1].to_set, [1].to_set, (1..5).to_set)
        end
      end

      context "uncommitted_changes" do
        context "when include_uncommitted is not specified" do
          let(:params) { base_params.merge({include_untracked: false}) }

          it { should be_a QuietQuality::ChangedFiles }

          it "should include the uncommitted files" do
            expect(changed_files.files.map(&:path)).to include("i.txt")
          end

          it "should include the uncommitted line numbers" do
            expect(changed_files.files.map(&:lines)).to include((1..3).to_set)
          end
        end

        context "when include_uncommitted: true (default)" do
          let(:params) { base_params.merge({include_uncommitted: true, include_untracked: false}) }

          it { should be_a QuietQuality::ChangedFiles }

          it "should include the uncommitted files" do
            expect(changed_files.files.map(&:path)).to include("i.txt")
          end

          it "should include the uncommitted line numbers" do
            expect(changed_files.files.map(&:lines)).to include((1..3).to_set)
          end
        end

        context "when include_uncommitted: false" do
          let(:params) { base_params.merge({include_uncommitted: false, include_untracked: false}) }

          it "should not include the uncommitted files" do
            expect(changed_files.files.map(&:path)).not_to include("i.txt")
          end

          it "should not include the uncommitted line numbers" do
            expect(changed_files.files.map(&:lines)).not_to include((1..3).to_set)
          end
        end
      end

      context "untracked_changes" do
        context "when include_untracked is not specified" do
          let(:params) { base_params.merge({include_uncommitted: false}) }

          it "should not include the untracked files" do
            expect(changed_files.files.map(&:path)).not_to include("j.txt")
          end

          it "should not include the untracked line numbers" do
            expect(changed_files.files.map(&:lines)).not_to include (1..8).to_set
          end
        end

        context "when include_untracked: false (default)" do
          let(:params) { base_params.merge({include_uncommitted: false, include_untracked: false}) }

          it "should not include the untracked files" do
            expect(changed_files.files.map(&:path)).not_to include("j.txt")
          end

          it "should not include the untracked line numbers" do
            expect(changed_files.files.map(&:lines)).not_to include (1..8).to_set
          end
        end

        context "when include_untracked: true" do
          let(:params) { base_params.merge({include_uncommitted: false, include_untracked: true}) }

          it "should not include the untracked files" do
            expect(changed_files.files.map(&:path)).to include("j.txt")
          end

          it "should not include the untracked line numbers" do
            expect(changed_files.file("j.txt").entire?).to eq true
          end
        end
      end
    end

    describe "#default_branch" do
      subject(:default_branch) { instance.default_branch }
      before { allow(instance).to receive_message_chain("git", "remote", "url").and_return("tmp/repo")}
      it { should eq "branch-1" }
    end

    describe "#comparison_base" do
      let(:sha) { "main" }
      let(:branch) { "branch-1" }
      subject(:comparison_base) { instance.comparison_base(sha: sha, comparison_branch: branch) }
      it { is_expected.to eq("d1e4d54ffff66d229cebe8cf8e9530b61998e119") }
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
