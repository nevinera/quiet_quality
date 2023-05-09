shared_examples "executes the pipelines" do
  let(:rspec_outcome) { build_success(:rspec, "fake_output") }
  let(:rspec_messages) { empty_messages }
  let(:rspec_pipeline) { instance_double(QuietQuality::Executors::Pipeline, outcome: rspec_outcome, messages: rspec_messages, failure?: rspec_outcome.failure?) }
  before { allow(QuietQuality::Executors::Pipeline).to receive(:new).with(tool_options: rspec_options, changed_files: changed_files).and_return(rspec_pipeline) }

  let(:rubocop_outcome) { build_success(:rubocop, "rubocop output") }
  let(:rubocop_messages) { empty_messages }
  let(:rubocop_pipeline) { instance_double(QuietQuality::Executors::Pipeline, outcome: rubocop_outcome, messages: rubocop_messages, failure?: rubocop_outcome.failure?) }
  before { allow(QuietQuality::Executors::Pipeline).to receive(:new).with(tool_options: rubocop_options, changed_files: changed_files).and_return(rubocop_pipeline) }

  describe "#execute!" do
    subject(:execute!) { executor.execute! }

    context "when both pipelines pass" do
      it { is_expected.to be_truthy }
    end

    context "when one of the pipelines fails" do
      let(:rubocop_outcome) { build_failure(:rubocop, "rubocop output") }
      it { is_expected.to be_falsey }
    end
  end

  describe "#outcomes" do
    subject(:outcomes) { executor.outcomes }
    it { is_expected.to contain_exactly(rspec_outcome, rubocop_outcome) }
  end

  describe "#messages" do
    subject(:messages) { executor.messages }

    context "when the pipelines all produce empty messages" do
      it { is_expected.to be_a(QuietQuality::Messages) }
      it { is_expected.to be_empty }
    end

    context "when the pipelines all produce nonempty messages" do
      let(:rubocop_messages) { full_messages(5) }
      let(:rspec_messages) { full_messages(2) }
      it { is_expected.to be_a(QuietQuality::Messages) }

      it "contains both sets of messages" do
        expect(messages.count).to eq(7)
      end
    end
  end

  describe "#any_failure?" do
    subject(:any_failure?) { executor.any_failure? }

    context "when both pipelines pass" do
      it { is_expected.to be_falsey }
    end

    context "when one of the pipelines fails" do
      let(:rubocop_outcome) { build_failure(:rubocop, "rubocop output") }
      it { is_expected.to be_truthy }
    end
  end
end
