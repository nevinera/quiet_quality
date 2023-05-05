RSpec.describe QuietQuality::ChangedFiles do
  let(:foo_file) { QuietQuality::ChangedFile.new(path: "path/foo.rb", lines: [1, 2, 3, 5, 10]) }
  let(:bar_file) { QuietQuality::ChangedFile.new(path: "path/bar.rb", lines: [5, 6, 7, 14, 15]) }
  let(:bug_file) { QuietQuality::ChangedFile.new(path: "path/bug.py", lines: :all) }
  let(:files) { [foo_file, bar_file, bug_file] }
  subject(:changed_files) { described_class.new(files) }

  describe "#files" do
    subject { changed_files.files }
    it { is_expected.to contain_exactly(foo_file, bar_file, bug_file) }
  end

  describe "#file" do
    subject { changed_files.file(path) }

    context "for a path that matches one of the files" do
      let(:path) { bar_file.path }
      it { is_expected.to eq(bar_file) }
    end

    context "for a path that doesn't match any file" do
      let(:path) { "path/baz.js" }
      it { is_expected.to be_nil }
    end
  end

  describe "#include?" do
    subject { changed_files.include?(path) }

    context "for a path that matches one of the files" do
      let(:path) { foo_file.path }
      it { is_expected.to be_truthy }
    end

    context "for a path that doesn't match any file" do
      let(:path) { "path/baz.js" }
      it { is_expected.to be_falsey }
    end
  end

  describe "#merge" do
    subject { changed_files.merge(other) }

    let(:foo2) { QuietQuality::ChangedFile.new(path: "path/foo.rb", lines: [4, 5, 8]) }
    let(:bug2) { QuietQuality::ChangedFile.new(path: "path/bug.py", lines: [14, 44]) }
    let(:baz2) { QuietQuality::ChangedFile.new(path: "path/baz.rb", lines: [1, 2, 3]) }
    let(:other) { described_class.new([foo2, bug2, baz2]) }

    it { is_expected.to be_a(described_class) }

    it "includes the right paths" do
      expect(subject.files.map(&:path))
        .to contain_exactly("path/foo.rb", "path/bar.rb", "path/bug.py", "path/baz.rb")
    end

    it "has merged those files as expected" do
      expect(subject.file("path/foo.rb").lines).to contain_exactly(1, 2, 3, 4, 5, 8, 10)
      expect(subject.file("path/bar.rb").lines).to contain_exactly(5, 6, 7, 14, 15)
      expect(subject.file("path/bug.py")).to be_entire
      expect(subject.file("path/baz.rb").lines).to contain_exactly(1, 2, 3)
    end
  end
end
