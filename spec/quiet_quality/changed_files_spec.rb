RSpec.describe QuietQuality::ChangedFiles do
  let(:foo_file) { QuietQuality::ChangedFile.new(path: "path/foo.rb", lines: [1, 2, 3, 5, 10]) }
  let(:bar_file) { QuietQuality::ChangedFile.new(path: "path/bar.rb", lines: [5, 6, 7, 14, 15]) }
  let(:files) { [foo_file, bar_file] }
  subject(:changed_files) { described_class.new(files) }

  describe "#files" do
    subject { changed_files.files }
    it { is_expected.to contain_exactly(foo_file, bar_file) }
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
end
