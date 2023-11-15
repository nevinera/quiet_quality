RSpec.describe QuietQuality::Executors::Execcer do
  let(:limit_targets?) { true }
  let(:file_filter) { ".*" }
  let(:tool_name) { :rspec }
  let(:tool_opts) { tool_options(tool_name, limit_targets: limit_targets?, file_filter: file_filter) }

  let(:foo_file) { QuietQuality::ChangedFile.new(path: "path/foo.rb", lines: [1, 2, 3, 5, 10]) }
  let(:bar_file) { QuietQuality::ChangedFile.new(path: "path/bar.rb", lines: [5, 6, 7, 14, 15]) }
  let(:bug_file) { QuietQuality::ChangedFile.new(path: "path/bug.rb", lines: :all) }
  let(:changed_files) { QuietQuality::ChangedFiles.new([foo_file, bar_file, bug_file]) }

  let(:runner_class) { QuietQuality::Tools::Rspec::Runner }
  let(:exec_command) { ["foo", "bar"] }
  let(:runner) { instance_double(runner_class, tool_name: :rspec, exec_command: exec_command) }
  before { allow(runner_class).to receive(:new).and_return(runner) }

  before { allow(Kernel).to receive(:exec) }
  before { allow(Kernel).to receive(:exit) }

  subject(:execcer) { described_class.new(tool_options: tool_opts, changed_files: changed_files) }

  describe "#exec!" do
    subject(:exec!) { execcer.exec! }

    context "when the targets are to be limited" do
      let(:limit_targets?) { true }

      it "sets up the runner correctly" do
        exec!
        expect(runner_class)
          .to have_received(:new)
          .with(changed_files: changed_files, file_filter: file_filter)
      end

      it "logs correctly" do
        exec!
        expect_info("Runner rspec exec_command: `foo bar`")
        expect_debug("Full exec_command for rspec", data: ["foo", "bar"])
      end

      it "calls Kernel.exec correctly" do
        exec!
        expect(Kernel).to have_received(:exec).with("foo", "bar")
        expect(Kernel).not_to have_received(:exit)
      end
    end

    context "when the targets are not to be limited" do
      let(:limit_targets?) { false }

      it "sets up the runner correctly" do
        exec!
        expect(runner_class)
          .to have_received(:new)
          .with(changed_files: nil, file_filter: file_filter)
      end

      it "logs correctly" do
        exec!
        expect_info("Runner rspec exec_command: `foo bar`")
        expect_debug("Full exec_command for rspec", data: ["foo", "bar"])
      end

      it "calls Kernel.exec correctly" do
        exec!
        expect(Kernel).to have_received(:exec).with("foo", "bar")
        expect(Kernel).not_to have_received(:exit)
      end
    end

    context "when the runner is skipping" do
      let(:limit_targets) { true }
      let(:exec_command) { nil }

      it "sets up the runner correctly" do
        exec!
        expect(runner_class)
          .to have_received(:new)
          .with(changed_files: changed_files, file_filter: file_filter)
      end

      it "logs correctly" do
        exec!
        expect_info("Runner rspec exec_command: (skipped)")
        expect_debug("Full exec_command for rspec", data: nil)
      end

      it "calls Kernel.exit instead of Kernel.exec" do
        exec!
        expect_info <<~LOG_MESSAGE
          This runner does not believe it needs to execute at all.
          This typically means that it was told to target changed-files, but no relevant
          files were changed.
        LOG_MESSAGE
        expect(Kernel).to have_received(:exit).with(0)
        expect(Kernel).not_to have_received(:exec)
      end
    end
  end
end
