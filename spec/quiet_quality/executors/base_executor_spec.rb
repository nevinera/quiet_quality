require_relative "executor_examples"

RSpec.describe QuietQuality::Executors::BaseExecutor do
  let(:rspec_options) { tool_options(:rspec, limit_targets: true, filter_messages: false) }
  let(:rubocop_options) { tool_options(:rubocop, limit_targets: false, filter_messages: true) }
  let(:tools) { [rspec_options, rubocop_options] }
  let(:changed_files) { instance_double(QuietQuality::ChangedFiles) }
  subject(:executor) { described_class.new(tools: tools, changed_files: changed_files) }

  include_examples "executes the pipelines"
end
