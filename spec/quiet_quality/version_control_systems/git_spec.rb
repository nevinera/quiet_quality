RSpec.describe QuietQuality::VersionControlSystems::Git do
  let(:path) { File.expand_path("../../../", __FILE__) }
  let(:instance) { described_class.new(path) }

  describe "#default_branch" do
    subject(:default_branch) { instance.default_branch }
    it { is_expected.to eq "main" }
  end

  describe "#comparison_base" do
    subject(:comparison_base) { instance.comparison_base(sha: "main", comparison_branch: "main") }

    it "delegates to the Git api" do
      expect(comparison_base.first.sha).to match(/^[a-z0-9]{40}$/)
    end
  end
end
