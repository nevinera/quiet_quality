RSpec.describe QuietQuality::Config::Finder do
  let(:from_dir) { fixture_path("config_finder_tree", "blue", "red") }
  subject(:finder) { described_class.new(from: from_dir) }

  before { stub_const("QuietQuality::Config::Finder::MAXIMUM_SEARCH_DEPTH", 3) }

  describe "#config_path" do
    subject(:config_path) { finder.config_path }

    it "is memoized" do
      config_path
      expect(Pathname).not_to receive(:new)
      config_path
    end

    context "when the config file is found" do
      context "in the supplied directory" do
        let(:from_dir) { fixture_path("config_finder_tree", "blue", "red") }
        it { is_expected.to eq(fixture_path("config_finder_tree", "blue", "red", ".quiet_quality.yml")) }
      end

      context "above the supplied directory" do
        let(:from_dir) { fixture_path("config_finder_tree", "bar", "buzz") }
        it { is_expected.to eq(fixture_path("config_finder_tree", "bar", ".quiet_quality.yml")) }
      end
    end

    context "when the config file is too far up the tree" do
      let(:from_dir) { fixture_path("config_finder_tree", "foo", "baz", "bam", "bim", "lum") }
      it { is_expected.to be_nil }
    end

    context "when the config file is in a subdirectory" do
      let(:from_dir) { fixture_path("config_finder_tree", "foo", "baz", "bam", "bim") }
      it { is_expected.to be_nil }
    end

    context "when the traversal reaches root" do
      let(:from_dir) { fixture_path("config_finder_tree", "foo", "baz") }
      before { allow_any_instance_of(Pathname).to receive(:root?).and_return(true) }
      it { is_expected.to be_nil }
    end

    context "when the traversal reaches an inaccessible directory" do
      let(:from_dir) { fixture_path("config_finder_tree", "foo", "baz") }
      let(:error) { Errno::EACCES.new("fake access error") }
      before { allow_any_instance_of(Pathname).to receive(:exist?).and_raise(error) }
      it { is_expected.to be_nil }
    end
  end
end
