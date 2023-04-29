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

  describe "#line_numbers" do
    subject { changed_file.line_numbers }
    it { is_expected.to be_an(Array) }
    it { is_expected.to eq([1, 3, 5, 9, 10]) }

    context "when the lines are out of order" do
      let(:lines) { [5, 1, 2, 9, 8] }
      it { is_expected.to eq([1, 2, 5, 8, 9]) }
    end
  end
end
