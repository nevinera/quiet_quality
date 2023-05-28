shared_examples "a functional BaseRunner subclass" do |tool_name, options|
  opts = options || {}
  success_statuses = opts.fetch(:success, [0])
  failure_statuses = opts.fetch(:failure, [1])
  error_statuses = opts.fetch(:error, [99])

  if opts[:runner_class_method]
    let(:runner_class) { send opts[:runner_class_method] }
  else
    let(:runner_class) { described_class }
  end

  # While it's possible for a BaseRunner to use these parameters, nothing implemented within
  # BaseRunner itself references them.
  let(:runner) { runner_class.new(changed_files: nil, file_filter: nil) }

  let(:out) { "fake stdout" }
  let(:err) { "fake stderr" }
  let(:stat) { mock_status(success_statuses.first) }
  before { allow(Open3).to receive(:capture3).and_return([out, err, stat]) }

  describe "#invoke!" do
    subject(:invoke!) { runner.invoke! }

    success_statuses.each do |success_status|
      context "with a (successful) exit status of #{success_status}" do
        let(:stat) { mock_status(success_status) }
        it { is_expected.to eq(build_outcome(tool: runner.tool_name, output: out, logging: err, failure: false)) }
      end
    end

    failure_statuses.each do |failure_status|
      context "with a (failing) exit status of #{failure_status}" do
        let(:stat) { mock_status(failure_status) }
        it { is_expected.to eq(build_outcome(tool: runner.tool_name, output: out, logging: err, failure: true)) }
      end
    end

    error_statuses.each do |error_status|
      context "with an (unexpected) exit status of #{error_status}" do
        let(:stat) { mock_status(error_status) }

        it "raises an ExecutionError" do
          expect { invoke! }.to raise_error(
            QuietQuality::Tools::ExecutionError,
            /Execution of #{runner.tool_name} failed with #{error_status}/
          )
        end
      end
    end
  end
end

shared_examples "a functional RelevantRunner subclass" do |tool_name, options|
  opts = options || {}
  success_statuses = opts.fetch(:success, [0])
  failure_statuses = opts.fetch(:failure, [1])
  error_statuses = opts.fetch(:error, [99])
  relevant_name = opts.fetch(:relevant)
  irrelevant_name = opts.fetch(:irrelevant)
  filter = opts.fetch(:filter)
  base_command = opts.fetch(:base_command)

  if opts[:runner_class_method]
    let(:runner_class) { send opts[:runner_class_method] }
  else
    let(:runner_class) { described_class }
  end

  let(:changed_files) { nil }
  let(:file_filter) { filter }
  let(:runner) { runner_class.new(changed_files: changed_files, file_filter: file_filter) }

  describe "#tool_name" do
    subject { runner.tool_name }
    it { is_expected.to be_a(Symbol) }
    it { is_expected.to eq(tool_name) }
  end

  describe "#relevant_path?" do
    subject(:relevant_path?) { runner.relevant_path?("/fake/path") }

    it "doesn't raise an error" do
      expect { relevant_path? }.not_to raise_error
    end
  end

  describe "#no_files_output" do
    subject(:no_files_output) { runner.no_files_output }
    it { is_expected.to be_a(String) }
  end

  describe "#command" do
    subject(:command) { runner.command }

    if base_command != :skip
      context "when there are no changes to consider" do
        let(:changed_files) { nil }
        it { is_expected.to eq(base_command) }
      end

      context "when there are changes to consider" do
        context "but they are empty" do
          let(:changed_files) { empty_changed_files }
          it { is_expected.to be_nil }
        end

        context "but they contain no files matching the relevance method" do
          let(:changed_files) { fully_changed_files(irrelevant_name) }
          it { is_expected.to be_nil }
        end

        context "and they contain some files that are relevant" do
          let(:changed_files) { fully_changed_files(relevant_name, irrelevant_name) }

          context "but none matching the file_filter" do
            let(:file_filter) { /never_gonna_give_you_up/ }
            it { is_expected.to be_nil }
          end

          context "and they also match the file_filter" do
            let(:file_filter) { /./ }
            it { is_expected.to eq(base_command + [relevant_name]) }

            context "but there are _too many_ of them" do
              before { stub_const("QuietQuality::Tools::RelevantRunner::MAX_FILES", 0) }
              it { is_expected.to eq(base_command) }
            end
          end
        end
      end
    end
  end

  describe "#invoke!" do
    subject(:invoke!) { runner.invoke! }

    let(:out) { "fake stdout" }
    let(:err) { "fake stderr" }
    let(:stat) { mock_status(0) }
    before { allow(Open3).to receive(:capture3).and_return([out, err, stat]) }

    shared_examples "exposes the successful command output" do
      it { is_expected.to eq(build_success(tool_name, out, err)) }

      it "invokes the tool with the command" do
        invoke!
        expect(Open3).to have_received(:capture3).with(*runner.command)
      end
    end

    shared_examples "skips the command and succeeds immediately" do
      it { is_expected.to eq(build_success(tool_name, runner.no_files_output)) }

      it "invokes the tool with the command" do
        invoke!
        expect(Open3).not_to have_received(:capture3)
      end
    end

    context "when there are no changes to consider" do
      let(:changed_files) { nil }
      include_examples "exposes the successful command output"
    end

    context "when there are changes to consider" do
      context "but they are empty" do
        let(:changed_files) { empty_changed_files }
        include_examples "skips the command and succeeds immediately"
      end

      context "but they contain no files matching the relevance method" do
        let(:changed_files) { fully_changed_files(irrelevant_name) }
        include_examples "skips the command and succeeds immediately"
      end

      context "and they contain some files that are relevant" do
        let(:changed_files) { fully_changed_files(relevant_name, irrelevant_name) }

        context "but none matching the file_filter" do
          let(:file_filter) { /never_gonna_let_you_down/ }
          include_examples "skips the command and succeeds immediately"
        end

        context "and they also match the file_filter" do
          let(:file_filter) { /./ }
          include_examples "exposes the successful command output"
        end
      end
    end

    success_statuses.each do |success_status|
      context "with a (successful) exit status of #{success_status}" do
        let(:stat) { mock_status(success_status) }
        it { is_expected.to eq(build_outcome(tool: runner.tool_name, output: out, logging: err, failure: false)) }
      end
    end

    failure_statuses.each do |failure_status|
      context "with a (failing) exit status of #{failure_status}" do
        let(:stat) { mock_status(failure_status) }
        it { is_expected.to eq(build_outcome(tool: runner.tool_name, output: out, logging: err, failure: true)) }
      end
    end

    error_statuses.each do |error_status|
      context "with an (unexpected) exit status of #{error_status}" do
        let(:stat) { mock_status(error_status) }

        it "raises an ExecutionError" do
          expect { invoke! }.to raise_error(
            QuietQuality::Tools::ExecutionError,
            /Execution of #{runner.tool_name} failed with #{error_status}/
          )
        end
      end
    end
  end
end
