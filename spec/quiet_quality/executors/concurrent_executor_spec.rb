require_relative "./executor_examples"

RSpec.describe QuietQuality::Executors::ConcurrentExecutor do
  let(:rspec_options) { QuietQuality::ToolOptions.new(:rspec, limit_targets: true, filter_messages: false) }
  let(:rubocop_options) { QuietQuality::ToolOptions.new(:rubocop, limit_targets: false, filter_messages: true) }
  let(:tools) { [rspec_options, rubocop_options] }
  let(:changed_files) { instance_double(QuietQuality::ChangedFiles) }
  subject(:executor) { described_class.new(tools: tools, changed_files: changed_files) }

  include_examples "executes the pipelines"
end
