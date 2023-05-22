RSpec.describe QuietQuality::Tools::HamlLint::Runner do
  let(:changed_files) { nil }
  subject(:runner) { described_class.new(changed_files: changed_files) }

  let(:exitstatus) { 0 }
  before { stub_capture3(status: exitstatus) }

  describe "#invoke!" do
    subject(:invoke!) { runner.invoke! }

    context "when haml-lint fails" do
      let(:exitstatus) { 3 }

      it "raises a HamlLint::ExecutionError" do
        expect { invoke! }.to raise_error(QuietQuality::Tools::HamlLint::ExecutionError)
      end
    end

    context "when there are linter rules broken" do
      let(:exitstatus) { 65 }
      it { is_expected.to eq(build_failure(:haml_lint, "fake output", "fake error")) }

      it "calls haml-lint with no targets" do
        invoke!
        expect(Open3).to have_received(:capture3).with("haml-lint", "--reporter", "json")
      end
    end

    context "when changed_files is nil" do
      let(:changed_files) { nil }
      it { is_expected.to eq(build_success(:haml_lint, "fake output", "fake error")) }

      it "calls haml-lint with no targets" do
        invoke!
        expect(Open3).to have_received(:capture3).with("haml-lint", "--reporter", "json")
      end
    end

    context "when changed_files is empty" do
      let(:changed_files) { empty_changed_files }
      it { is_expected.to eq(build_success(:haml_lint, described_class::NO_FILES_OUTPUT)) }

      it "does not call haml-lint" do
        expect(Open3).not_to have_received(:capture3)
      end
    end

    context "when changed_files is full" do
      context "but contains no haml files" do
        let(:changed_files) { generate_changed_files({"foo_spec.ts" => :all, "bar.rb" => [1, 2], "baz_spec.rb.bak" => [5]}) }
        it { is_expected.to eq(build_success(:haml_lint, described_class::NO_FILES_OUTPUT)) }

        it "does not call haml-lint" do
          expect(Open3).not_to have_received(:capture3)
        end
      end

      context "and contains some haml files" do
        let(:changed_paths) { ["foo.html", "bar.haml.erb", "baz.html.haml", "bam.haml"] }
        let(:changed_files) { generate_changed_files(changed_paths.map { |p| [p, :all] }.to_h) }
        it { is_expected.to eq(build_success(:haml_lint, "fake output", "fake error")) }

        it "calls haml-lint with the correct targets" do
          invoke!
          expect(Open3)
            .to have_received(:capture3)
            .with("haml-lint", "--reporter", "json", "bam.haml", "baz.html.haml")
        end
      end
    end
  end
end
