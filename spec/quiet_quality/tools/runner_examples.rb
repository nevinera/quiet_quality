shared_examples "a functional BaseRunner subclass" do |tool_name, opts|
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
