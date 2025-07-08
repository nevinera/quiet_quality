require_relative "../runner_examples"

RSpec.describe QuietQuality::Tools::Rspec::Runner do
  let(:changed_files) { nil }
  let(:file_filter) { nil }
  subject(:runner) { described_class.new(changed_files: changed_files, file_filter: file_filter) }

  it_behaves_like "a functional RelevantRunner subclass", :rspec, {
    relevant: "foo_spec.rb",
    irrelevant: "bar.ts",
    filter: /\.rb/,
    base_command: ["rspec", "-f", "json"],
    base_exec_command: ["rspec"]
  }

  describe "#tool_name" do
    subject(:tool_name) { runner.tool_name }
    it { is_expected.to eq(:rspec) }
  end

  describe "#no_files_output" do
    subject { runner.no_files_output }
    let(:parsed) { JSON.parse(subject) }

    it "contains the expected data" do
      expect(parsed.dig("examples")).to eq([])
      expect(parsed.dig("summary", "failure_count")).to eq(0)
    end
  end

  describe "#base_command" do
    subject(:base_command) { runner.base_command }
    it { is_expected.to eq(["rspec", "-f", "json"]) }
  end

  describe "#base_exec_command" do
    subject(:base_exec_command) { runner.base_exec_command }
    it { is_expected.to eq(["rspec"]) }
  end

  describe "#relevant_path?" do
    subject(:relevant_path?) { runner.relevant_path?(path) }

    context "for a random other file" do
      let(:path) { "foo/bar.ts" }
      it { is_expected.to be_falsey }
    end

    context "for a non-spec ruby file" do
      let(:path) { "foo/bar.rb" }
      it { is_expected.to be_falsey }
    end

    context "for a ruby spec file" do
      let(:path) { "foo/bar_spec.rb" }
      it { is_expected.to be_truthy }
    end

    context "for a weirdly named, but non-spec file" do
      let(:path) { "foo/bar_spec.rb.txt" }
      it { is_expected.to be_falsey }
    end
  end

  def self.it_considers(status:, to_be:)
    context "when the process exits with #{status}" do
      let(:stat) { mock_status(status) }
      it { is_expected.to eq(to_be) }
    end
  end

  describe "#success_status?" do
    subject(:success_status?) { runner.success_status?(stat) }

    context "when running with 'changed_files'" do
      let(:changed_files) { fully_changed_files("/tmp/foo") }
      it_considers(status: 0, to_be: true)
      it_considers(status: 1, to_be: false)
      it_considers(status: 2, to_be: true)
      it_considers(status: 3, to_be: true)
      it_considers(status: 99, to_be: false)
    end

    context "when running without 'changed_files'" do
      let(:changed_files) { nil }
      it_considers(status: 0, to_be: true)
      it_considers(status: 1, to_be: false)
      it_considers(status: 2, to_be: false)
      it_considers(status: 3, to_be: false)
      it_considers(status: 99, to_be: false)
    end
  end

  describe "#failure_status?" do
    subject(:failure_status) { runner.failure_status?(stat) }

    context "when running with 'changed_files'" do
      let(:changed_files) { fully_changed_files("/tmp/foo") }
      it_considers(status: 0, to_be: false)
      it_considers(status: 1, to_be: true)
      it_considers(status: 2, to_be: false)
      it_considers(status: 3, to_be: false)
      it_considers(status: 99, to_be: false)
    end

    context "when running without 'changed_files'" do
      let(:changed_files) { nil }
      it_considers(status: 0, to_be: false)
      it_considers(status: 1, to_be: true)
      it_considers(status: 2, to_be: true)
      it_considers(status: 3, to_be: true)
      it_considers(status: 99, to_be: false)
    end
  end
end
