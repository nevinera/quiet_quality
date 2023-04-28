RSpec.describe QuietQuality::ChangedFile do
  let(:path) { "foo/bar.rb" }
  let(:lines) { [1, 3, 5, 9, 10] }
  subject(:changed_file) { described_class.new(path: path, lines: lines) }

  describe "#path" do
    subject { changed_file.path }
    it { is_expected.to be_a(String) }
    it { is_expected.to eq(path) }
  end

  describe "#lines" do
    subject { changed_file.lines }
    it { is_expected.to be_a(Set) }
    it { is_expected.to contain_exactly(1, 3, 5, 9, 10) }
  end
end
