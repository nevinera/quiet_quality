require_relative "../runner_examples"

RSpec.describe QuietQuality::Tools::Rubocop::Runner do
  let(:changed_files) { nil }
  let(:file_filter) { nil }
  subject(:runner) { described_class.new(changed_files: changed_files, file_filter: file_filter) }

  it_behaves_like "a functional RelevantRunner subclass", :rubocop, {
    relevant: "foo.rb",
    irrelevant: "foo.ts",
    filter: /foo/,
    base_command: ["rubocop", "-f", "json"]
  }

  describe "#tool_name" do
    subject(:tool_name) { runner.tool_name }
    it { is_expected.to eq(:rubocop) }
  end

  describe "#no_files_output" do
    subject { runner.no_files_output }
    let(:parsed) { JSON.parse(subject) }

    it "contains the expected data" do
      expect(parsed.dig("files")).to eq([])
      expect(parsed.dig("summary", "offense_count")).to eq(0)
    end
  end

  describe "#base_command" do
    subject(:base_command) { runner.base_command }
    it { is_expected.to eq(["rubocop", "-f", "json"]) }
  end

  describe "#relevant_path?" do
    subject(:relevant_path?) { runner.relevant_path?(path) }

    context "for a random other file" do
      let(:path) { "foo/bar.ts" }
      it { is_expected.to be_falsey }
    end

    context "for a ruby file" do
      let(:path) { "foo/bar.rb" }
      it { is_expected.to be_truthy }
    end

    context "for a weirdly named, but non-ruby file" do
      let(:path) { "foo/bar.rb.txt" }
      it { is_expected.to be_falsey }
    end
  end
end
