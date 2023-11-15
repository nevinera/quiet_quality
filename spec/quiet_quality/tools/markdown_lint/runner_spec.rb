require_relative "../runner_examples"

RSpec.describe QuietQuality::Tools::MarkdownLint::Runner do
  let(:changed_files) { nil }
  let(:file_filter) { nil }
  subject(:runner) { described_class.new(changed_files: changed_files, file_filter: file_filter) }

  it_behaves_like "a functional RelevantRunner subclass", :markdown_lint, {
    relevant: "foo.md",
    irrelevant: "foo.txt",
    filter: /foo/,
    base_command: :skip,
    base_exec_command: :skip
  }

  describe "#tool_name" do
    subject(:tool_name) { runner.tool_name }
    it { is_expected.to eq(:markdown_lint) }
  end

  describe "#no_files_output" do
    subject { runner.no_files_output }
    let(:parsed) { JSON.parse(subject) }

    it "contains an empty array" do
      expect(parsed).to eq([])
    end
  end

  describe "#relevant_path?" do
    subject(:relevant_path?) { runner.relevant_path?(path) }

    context "for a random other file" do
      let(:path) { "foo/bar.txt" }
      it { is_expected.to be_falsey }
    end

    context "for a markdown file" do
      let(:path) { "foo/bar.md" }
      it { is_expected.to be_truthy }
    end

    context "for a weirdly named, but non-markdown file" do
      let(:path) { "foo/bar.md.txt" }
      it { is_expected.to be_falsey }
    end
  end

  describe "#command" do
    subject(:command) { runner.command }

    context "when there are no changed to consider" do
      let(:changed_files) { nil }
      it { is_expected.to eq(["mdl", "--json", "."]) }
    end

    context "when there are changed to consider" do
      context "but they are empty" do
        let(:changed_files) { empty_changed_files }
        it { is_expected.to be_nil }
      end

      context "but they contain no markdown files" do
        let(:changed_files) { fully_changed_files("foo.txt") }
        it { is_expected.to be_nil }
      end

      context "but they contain no files matching the file_filter" do
        let(:file_filter) { /baz/ }
        let(:changed_files) { fully_changed_files("foo.md", "bar.md") }
        it { is_expected.to be_nil }
      end

      context "and they contain some files that are relevant" do
        let(:file_filter) { /foo|bar/ }
        let(:changed_files) { fully_changed_files("foo.md", "bar.md", "baz.md", "foo.txt") }
        it { is_expected.to eq(["mdl", "--json", "bar.md", "foo.md"]) }
      end
    end
  end

  describe "#exec_command" do
    subject(:exec_command) { runner.exec_command }

    context "when there are no changed to consider" do
      let(:changed_files) { nil }
      it { is_expected.to eq(["mdl", "."]) }
    end

    context "when there are changed to consider" do
      context "but they are empty" do
        let(:changed_files) { empty_changed_files }
        it { is_expected.to be_nil }
      end

      context "but they contain no markdown files" do
        let(:changed_files) { fully_changed_files("foo.txt") }
        it { is_expected.to be_nil }
      end

      context "but they contain no files matching the file_filter" do
        let(:file_filter) { /baz/ }
        let(:changed_files) { fully_changed_files("foo.md", "bar.md") }
        it { is_expected.to be_nil }
      end

      context "and they contain some files that are relevant" do
        let(:file_filter) { /foo|bar/ }
        let(:changed_files) { fully_changed_files("foo.md", "bar.md", "baz.md", "foo.txt") }
        it { is_expected.to eq(["mdl", "bar.md", "foo.md"]) }
      end
    end
  end
end
