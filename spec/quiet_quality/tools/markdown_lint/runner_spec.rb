RSpec.describe QuietQuality::Tools::MarkdownLint::Runner do
  let(:changed_files) { nil }
  let(:file_filter) { nil }
  subject(:runner) { described_class.new(changed_files: changed_files, file_filter: file_filter) }

  let(:exitstatus) { 0 }
  before { stub_capture3(status: exitstatus) }

  describe "#invoke!" do
    subject(:invoke!) { runner.invoke! }

    context "when mdl fails" do
      let(:exitstatus) { 3 }

      it "raises a MarkdownLint::ExecutionError" do
        expect { invoke! }.to raise_error(QuietQuality::Tools::MarkdownLint::ExecutionError)
      end
    end

    context "when there are linter rules broken" do
      let(:exitstatus) { 1 }
      it { is_expected.to eq(build_failure(:markdown_lint, "fake output", "fake error")) }

      it "calls mdl with no targets" do
        invoke!
        expect(Open3).to have_received(:capture3).with("mdl", "--json", ".")
      end
    end

    context "when changed_files is nil" do
      let(:changed_files) { nil }
      it { is_expected.to eq(build_success(:markdown_lint, "fake output", "fake error")) }

      it "calls mdl on the current directory" do
        invoke!
        expect(Open3).to have_received(:capture3).with("mdl", "--json", ".")
      end
    end

    context "when changed_files is empty" do
      let(:changed_files) { empty_changed_files }
      it { is_expected.to eq(build_success(:markdown_lint, described_class::NO_FILES_OUTPUT)) }

      it "does not call mdl" do
        expect(Open3).not_to have_received(:capture3)
      end
    end

    context "when changed_files is full" do
      context "but contains no markdown files" do
        let(:changed_files) { generate_changed_files({"foo_spec.ts" => :all, "bar.rb" => [1, 2], "baz.md.bak" => [5]}) }
        it { is_expected.to eq(build_success(:markdown_lint, described_class::NO_FILES_OUTPUT)) }

        it "does not call mdl" do
          expect(Open3).not_to have_received(:capture3)
        end
      end

      context "and contains some markdown files" do
        let(:changed_paths) { ["foo.md", "bar.haml.erb", "baz.md", "bam.haml"] }
        let(:changed_files) { generate_changed_files(changed_paths.map { |p| [p, :all] }.to_h) }
        it { is_expected.to eq(build_success(:markdown_lint, "fake output", "fake error")) }

        it "calls mdl with the correct targets" do
          invoke!
          expect(Open3)
            .to have_received(:capture3)
            .with("mdl", "--json", "baz.md", "foo.md")
        end

        context "but some of them are filtered out" do
          let(:file_filter) { /foo/ }
          it { is_expected.to eq(build_success(:markdown_lint, "fake output", "fake error")) }

          it "calls mdl with the correct targets" do
            invoke!
            expect(Open3)
              .to have_received(:capture3)
              .with("mdl", "--json", "foo.md")
          end
        end

        context "but all of them are filtered out" do
          let(:file_filter) { /nobody/ }
          it { is_expected.to eq(build_success(:markdown_lint, described_class::NO_FILES_OUTPUT)) }

          it "does not call mdl" do
            expect(Open3).not_to have_received(:capture3)
          end
        end
      end
    end
  end
end
