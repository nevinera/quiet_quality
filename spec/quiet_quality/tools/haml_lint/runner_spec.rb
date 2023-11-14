require_relative "../runner_examples"

RSpec.describe QuietQuality::Tools::HamlLint::Runner do
  let(:changed_files) { nil }
  let(:file_filter) { nil }
  subject(:runner) { described_class.new(changed_files: changed_files, file_filter: file_filter) }

  it_behaves_like "a functional RelevantRunner subclass", :haml_lint, {
    relevant: "foo.html.haml",
    irrelevant: "foo.html.erb",
    filter: /foo/,
    base_command: ["haml-lint", "--reporter", "json"],
    base_exec_command: ["haml-lint"],
    failure: [65],
    error: [1, 2, 3, 99]
  }

  describe "#tool_name" do
    subject(:tool_name) { runner.tool_name }
    it { is_expected.to eq(:haml_lint) }
  end

  describe "#no_files_output" do
    subject { runner.no_files_output }
    let(:parsed) { JSON.parse(subject) }

    it "contains the expected data" do
      expect(parsed.dig("files")).to eq([])
    end
  end

  describe "#base_command" do
    subject(:base_command) { runner.base_command }
    it { is_expected.to eq(["haml-lint", "--reporter", "json"]) }
  end

  describe "#base_exec_command" do
    subject(:base_exec_command) { runner.base_exec_command }
    it { is_expected.to eq(["haml-lint"]) }
  end

  describe "#relevant_path?" do
    subject(:relevant_path?) { runner.relevant_path?(path) }

    context "for a random other file" do
      let(:path) { "foo/bar.erb" }
      it { is_expected.to be_falsey }
    end

    context "for a haml file" do
      let(:path) { "foo/bar.haml" }
      it { is_expected.to be_truthy }
    end

    context "for a weirdly named, but non-haml file" do
      let(:path) { "foo/bar.haml.erb" }
      it { is_expected.to be_falsey }
    end
  end
end
