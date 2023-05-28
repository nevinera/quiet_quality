RSpec.describe QuietQuality::Tools::Rubocop::Runner do
  let(:changed_files) { nil }
  let(:file_filter) { nil }
  subject(:runner) { described_class.new(changed_files: changed_files, file_filter: file_filter) }

  let(:out) { "fake output" }
  let(:err) { "fake error" }
  let(:stat) { instance_double(Process::Status, success?: true, exitstatus: 0) }
  before { allow(Open3).to receive(:capture3).and_return([out, err, stat]) }

  describe "#invoke!" do
    subject(:invoke!) { runner.invoke! }

    context "when the rubocop command _fails_" do
      let(:stat) { instance_double(Process::Status, success?: false, exitstatus: 14) }

      it "raises an ExecutionError" do
        expect { invoke! }.to raise_error(QuietQuality::Tools::ExecutionError)
      end
    end

    context "when the rubocop command _finds problems_" do
      let(:stat) { instance_double(Process::Status, success?: false, exitstatus: 1) }
      it { is_expected.to eq(build_failure(:rubocop, "fake output", "fake error")) }

      it "calls rubocop correctly, with no targets" do
        invoke!
        expect(Open3).to have_received(:capture3).with("rubocop", "-f", "json")
      end
    end

    context "when changed_files is nil" do
      let(:changed_files) { nil }
      it { is_expected.to eq(build_success(:rubocop, "fake output", "fake error")) }

      it "calls rubocop correctly, with no targets" do
        invoke!
        expect(Open3).to have_received(:capture3).with("rubocop", "-f", "json")
      end
    end

    context "when changed_files is empty" do
      let(:changed_files) { empty_changed_files }
      it { is_expected.to eq(build_success(:rubocop, described_class::NO_FILES_OUTPUT)) }

      it "does not call rubocop" do
        invoke!
        expect(Open3).not_to have_received(:capture3)
      end
    end

    context "when changed_files is full" do
      let(:file1) { "foo.js" }
      let(:file2) { "bar.rb" }
      let(:file3) { "baz.rb" }
      let(:changed_files) { fully_changed_files(file1, file2, file3) }

      context "but contains no ruby files" do
        let(:file2) { "bar.js" }
        let(:file3) { "baz.ts" }
        it { is_expected.to eq(build_success(:rubocop, described_class::NO_FILES_OUTPUT)) }

        it "does not call rubocop" do
          invoke!
          expect(Open3).not_to have_received(:capture3)
        end
      end

      context "and contains some ruby files" do
        it { is_expected.to eq(build_success(:rubocop, "fake output", "fake error")) }

        it "calls rubocop correctly, with changed and relevant targets" do
          invoke!
          expect(Open3)
            .to have_received(:capture3)
            .with("rubocop", "-f", "json", "bar.rb", "baz.rb")
        end

        context "but some of them are filtered out" do
          let(:file_filter) { /bar/ }
          it { is_expected.to eq(build_success(:rubocop, "fake output", "fake error")) }

          it "calls rubocop correctly, with changed and relevant targets" do
            invoke!
            expect(Open3)
              .to have_received(:capture3)
              .with("rubocop", "-f", "json", "bar.rb")
          end
        end

        context "but all of them are filtered out" do
          let(:file_filter) { /nobody/ }
          it { is_expected.to eq(build_success(:rubocop, described_class::NO_FILES_OUTPUT)) }

          it "does not call rubocop" do
            invoke!
            expect(Open3).not_to have_received(:capture3)
          end
        end
      end

      context "and contains too many ruby files" do
        before { stub_const("QuietQuality::Tools::Rubocop::Runner::MAX_FILES", 1) }
        it { is_expected.to eq(build_success(:rubocop, "fake output", "fake error")) }

        it "calls rubocop correctly, with no targets" do
          invoke!
          expect(Open3)
            .to have_received(:capture3)
            .with("rubocop", "-f", "json")
        end
      end
    end
  end
end
