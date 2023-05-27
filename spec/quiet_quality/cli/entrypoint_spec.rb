RSpec.describe QuietQuality::Cli::Entrypoint do
  let(:argv) { [] }
  let(:output_stream) { instance_double(IO, puts: nil) }
  let(:error_stream) { instance_double(IO, puts: nil) }
  subject(:entrypoint) { described_class.new(argv: argv, output_stream: output_stream, error_stream: error_stream) }

  let(:messages) { empty_messages }
  let(:outcomes) { [build_success(:rspec), build_success(:rubocop)] }
  let(:any_failure?) { outcomes.any?(&:failure?) }
  let!(:executor) do
    instance_double(
      QuietQuality::Executors::ConcurrentExecutor,
      execute!: nil,
      messages: messages,
      outcomes: outcomes,
      any_failure?: any_failure?,
      failed_outcomes: outcomes.select(&:failure?),
      successful_outcomes: outcomes.reject(&:failure?)
    )
  end
  before { allow(QuietQuality::Executors::ConcurrentExecutor).to receive(:new).and_return(executor) }

  let(:changed_files) { instance_double(QuietQuality::ChangedFiles) }
  let(:git) { instance_double(QuietQuality::VersionControlSystems::Git, changed_files: changed_files) }
  before { allow(QuietQuality::VersionControlSystems::Git).to receive(:new).and_return(git) }

  describe "#execute" do
    subject(:execute) { entrypoint.execute }

    context "when the tools all pass" do
      let(:messages) { empty_messages }
      let(:outcomes) { [build_success(:rspec), build_success(:rubocop)] }

      it { is_expected.to be_a(described_class) }
      it { is_expected.to eq(entrypoint) }
      it { is_expected.to be_successful }

      it "logs the outcomes properly" do
        execute
        expect(error_stream).to have_received(:puts).with("--- Passed: rspec")
        expect(error_stream).to have_received(:puts).with("--- Passed: rubocop")
      end

      context "when annotation is requested" do
        let(:argv) { ["--annotate", "github_stdout"] }

        it "prints no annotations" do
          execute
          expect(output_stream).not_to have_received(:puts)
        end
      end

      context "when annotation is not requested" do
        let(:argv) { [] }

        it "prints no annotations" do
          execute
          expect(output_stream).not_to have_received(:puts)
        end
      end
    end

    context "when some of the tools fail" do
      let(:outcomes) { [build_failure(:rspec), build_success(:rubocop)] }
      let(:m1) { QuietQuality::Message.new(path: "foo.rb", body: "Msg1", start_line: 1) }
      let(:m2) { QuietQuality::Message.new(path: "bar.rb", body: "Msg2", start_line: 2, rule: "Title") }
      let(:m3) { QuietQuality::Message.new(path: "baz.rb", body: "Msg3", start_line: 3, stop_line: 7, annotated_line: 5) }
      let(:messages) { QuietQuality::Messages.new([m1, m2, m3]) }

      it { is_expected.to be_a(described_class) }
      it { is_expected.to eq(entrypoint) }
      it { is_expected.not_to be_successful }

      shared_examples "annotations are requested" do
        it "writes the proper annotations to stdout" do
          execute
          expect(output_stream).to have_received(:puts).with("::warning file=foo.rb,line=1::Msg1")
          expect(output_stream).to have_received(:puts).with("::warning file=bar.rb,line=2,title=Title::Msg2")
          expect(output_stream).to have_received(:puts).with("::warning file=baz.rb,line=5::Msg3")
        end
      end

      it "logs the outcomes properly" do
        execute
        expect(error_stream).to have_received(:puts).with("--- Failed: rspec")
        expect(error_stream).to have_received(:puts).with("--- Passed: rubocop")
      end

      it "logs the messages properly" do
        execute
        expect(error_stream).to have_received(:puts).with("  foo.rb:1  Msg1")
        expect(error_stream).to have_received(:puts).with("  bar.rb:2  [Title]  Msg2")
        expect(error_stream).to have_received(:puts).with("  baz.rb:3-7  Msg3")
      end

      context "when annotation is requested" do
        let(:argv) { ["--annotate", "github_stdout"] }

        include_examples "annotations are requested"
      end

      context "when annotation is not requested" do
        let(:argv) { [] }

        it "prints no annotations" do
          execute
          expect(output_stream).not_to have_received(:puts)
        end
      end

      context "when logging is quiet" do
        let(:argv) { ["--quiet"] }

        it "does not print the messages" do
          execute
          expect(output_stream).not_to have_received(:puts)
          expect(error_stream).not_to have_received(:puts)
        end

        context "with annotations requested" do
          let(:argv) { ["--quiet", "--annotate", "github_stdout"] }

          include_examples "annotations are requested"
        end
      end

      context "when logging is light" do
        let(:argv) { ["--light"] }

        it "does not print the messages" do
          execute
          expect(error_stream).not_to have_received(:puts).with("  foo.rb:1  Msg1")
          expect(error_stream).not_to have_received(:puts).with("  bar.rb:2  [Title]  Msg2")
          expect(error_stream).not_to have_received(:puts).with("  baz.rb:3-7  Msg3")
        end

        it "does not print the standard outcomes" do
          execute
          expect(error_stream).not_to have_received(:puts).with("--- Failed: rspec")
          expect(error_stream).not_to have_received(:puts).with("--- Passed: rubocop")
        end

        it "prints the aggregated outcomes" do
          execute
          expect(output_stream).to have_received(:puts).with(
            "2 tools executed: 1 passed, 1 failed (rspec)"
          )
        end

        context "when annotations are requested" do
          let(:argv) { ["--light", "--annotate", "github_stdout"] }

          include_examples "annotations are requested"
        end
      end
    end

    context "when asked for --help" do
      let(:argv) { ["--help"] }

      it { is_expected.to be_successful }

      it "does not run the executor" do
        execute
        expect(executor).not_to have_received(:execute!)
      end

      it "prints the help information to the error stream" do
        execute
        expect(error_stream).to have_received(:puts).with(a_string_matching(/Usage:/))
      end
    end

    context "when asked for --version" do
      let(:argv) { ["--version"] }

      it { is_expected.to be_successful }

      it "does not run the executor" do
        execute
        expect(executor).not_to have_received(:execute!)
      end

      it "prints the help information to the error stream" do
        execute
        expect(error_stream).to have_received(:puts).with(QuietQuality::VERSION)
      end
    end
  end

  describe "#successful?" do
    subject(:successful?) { entrypoint.successful? }

    context "when the executor reports a failure" do
      let(:any_failure?) { true }
      it { is_expected.to be_falsey }
    end

    context "when the executor reports no failure" do
      let(:any_failure?) { false }
      it { is_expected.to be_truthy }
    end

    context "when asked for --help" do
      let(:argv) { ["--help"] }
      it { is_expected.to be_truthy }
    end

    context "when asked for --version" do
      let(:argv) { ["--version"] }
      it { is_expected.to be_truthy }
    end
  end
end
