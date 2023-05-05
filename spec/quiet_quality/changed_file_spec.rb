RSpec.describe QuietQuality::ChangedFile do
  let(:path) { "foo/bar.rb" }
  let(:lines) { [1, 3, 5, 9, 10] }
  subject(:changed_file) { described_class.new(path: path, lines: lines) }

  describe "#path" do
    subject { changed_file.path }
    it { is_expected.to be_a(String) }
    it { is_expected.to eq(path) }
  end

  describe "#entire?" do
    subject { changed_file.entire? }

    context "when passed an array of line numbers" do
      let(:lines) { [1, 3, 5, 9, 10] }
      it { is_expected.to be_falsey }
    end

    context "when passed the sentinel value :all" do
      let(:lines) { :all }
      it { is_expected.to be_truthy }
    end

    context "when passed the sentinel value 'all'" do
      let(:lines) { "all" }
      it { is_expected.to be_truthy }
    end
  end

  describe "#lines" do
    subject { changed_file.lines }

    context "when passed an array of line numbers" do
      let(:lines) { [1, 3, 5, 9, 10] }
      it { is_expected.to be_a(Set) }
      it { is_expected.to contain_exactly(1, 3, 5, 9, 10) }
    end

    context "when passed the sentinel value :all" do
      let(:lines) { :all }
      it { is_expected.to be_nil }
    end

    context "when passed the sentinel value 'all'" do
      let(:lines) { "all" }
      it { is_expected.to be_nil }
    end
  end

  describe "#line_numbers" do
    subject { changed_file.line_numbers }

    context "when passed an array of line numbers" do
      let(:lines) { [1, 3, 5, 9, 10] }
      it { is_expected.to be_an(Array) }
      it { is_expected.to eq([1, 3, 5, 9, 10]) }

      context "when the lines are out of order" do
        let(:lines) { [5, 1, 2, 9, 8] }
        it { is_expected.to eq([1, 2, 5, 8, 9]) }
      end
    end

    context "when passed the sentinel value :all" do
      let(:lines) { :all }
      it { is_expected.to be_nil }
    end

    context "when passed the sentinel value 'all'" do
      let(:lines) { "all" }
      it { is_expected.to be_nil }
    end
  end

  describe "#merge" do
    subject { changed_file.merge(other) }

    context "when the two files have different paths" do
      let(:other) { described_class.new(path: "/wrong", lines: [5, 7, 9]) }

      it "raises an ArgumentError" do
        expect { subject }.to raise_error(ArgumentError, /Cannot merge/)
      end
    end

    context "when the first file is 'entire'" do
      let(:lines) { :all }
      let(:other) { described_class.new(path: path, lines: [5, 7]) }
      it { is_expected.to be_a(described_class) }
      it { is_expected.to be_entire }

      it "has the expected path" do
        expect(subject.path).to eq(path)
      end
    end

    context "when the second file is 'entire'" do
      let(:other) { described_class.new(path: path, lines: :all) }
      it { is_expected.to be_a(described_class) }
      it { is_expected.to be_entire }

      it "has the expected path" do
        expect(subject.path).to eq(path)
      end
    end

    context "when the lists of lines overlap" do
      let(:other) { described_class.new(path: path, lines: [5, 6, 7, 64]) }
      it { is_expected.to be_a(described_class) }
      it { is_expected.not_to be_entire }

      it "has the expected path" do
        expect(subject.path).to eq(path)
      end

      it "has the expected lines" do
        expect(subject.lines).to contain_exactly(1, 3, 5, 6, 7, 9, 10, 64)
        expect(subject.lines).to be_a(Set)
        expect(subject.line_numbers).to be_an(Array)
      end
    end
  end
end
