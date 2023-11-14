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
  let(:execcer) { instance_double(QuietQuality::Executors::Execcer, exec!: nil) }
  before { allow(QuietQuality::Executors::Execcer).to receive(:new).and_return(execcer) }

  let(:changed_files) { instance_double(QuietQuality::ChangedFiles) }
  let(:git) { instance_double(QuietQuality::VersionControlSystems::Git, changed_files: changed_files) }
  before { allow(QuietQuality::VersionControlSystems::Git).to receive(:new).and_return(git) }

  let(:options) { build_options(rubocop: {}, rspec: {}) }
  let(:config_builder) { instance_double(QuietQuality::Config::Builder, options: options) }
  before { allow(QuietQuality::Config::Builder).to receive(:new).and_return(config_builder) }

  let(:presenter_class) { QuietQuality::Cli::Presenter }
  let(:presenter) { instance_double(presenter_class, log_results: nil) }
  before { allow(presenter_class).to receive(:new).and_return(presenter) }

  describe "#execute" do
    subject(:execute) { entrypoint.execute }

    it "logs the options (at debug level)" do
      execute
      expect_debug("Complete Options object:", data: options.to_h)
    end

    context "when the tools all pass" do
      let(:messages) { empty_messages }
      let(:outcomes) { [build_success(:rspec), build_success(:rubocop)] }

      it { is_expected.to be_a(described_class) }
      it { is_expected.to eq(entrypoint) }
      it { is_expected.to be_successful }

      it "presents the outcomes properly" do
        execute
        expect(presenter_class).to have_received(:new).with(
          stream: error_stream,
          options: options,
          outcomes: outcomes,
          messages: messages
        )
        expect(presenter).to have_received(:log_results)
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
      let(:m1) { QuietQuality::Message.new(path: "foo.rb", body: "Msg1", start_line: 1, tool_name: :just_delete_everything) }
      let(:m2) { QuietQuality::Message.new(path: "bar.rb", body: "Msg2", start_line: 2, rule: "Title", tool_name: :complexity_checks_that_make_things_worse) }
      let(:m3) { QuietQuality::Message.new(path: "baz.rb", body: "Msg3", start_line: 3, stop_line: 7, annotated_line: 5, tool_name: :not_enough_extra_newlines) }
      let(:messages) { QuietQuality::Messages.new([m1, m2, m3]) }

      it { is_expected.to be_a(described_class) }
      it { is_expected.to eq(entrypoint) }
      it { is_expected.not_to be_successful }

      it "presents the outcomes properly" do
        execute
        expect(presenter_class).to have_received(:new).with(
          stream: error_stream,
          options: options,
          outcomes: outcomes,
          messages: messages
        )
        expect(presenter).to have_received(:log_results)
      end

      context "when annotation is requested" do
        let(:argv) { ["--annotate", "github_stdout"] }
        let(:options) { build_options(annotator: :github_stdout, rubocop: {}, rspec: {}) }

        it "writes the proper annotations to stdout" do
          execute
          expect(output_stream).to have_received(:puts).with("::warning file=foo.rb,line=1,title=just_delete_everything::Msg1")
          expect(output_stream).to have_received(:puts).with("::warning file=bar.rb,line=2,title=complexity_checks_that_make_things_worse Title::Msg2")
          expect(output_stream).to have_received(:puts).with("::warning file=baz.rb,line=5,title=not_enough_extra_newlines::Msg3")
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

    context "when there are no tools to run" do
      let(:options) { build_options(annotator: :github_stdout) }

      it "does not run the executor" do
        execute
        expect(executor).not_to have_received(:execute!)
      end

      it "prints the corrective instructions to the error stream" do
        execute
        expect(error_stream)
          .to have_received(:puts)
          .with(a_string_matching(/specify one or more tools to run/))
      end
    end

    context "when told to exec the rspec tool" do
      let(:options) { build_options(rubocop: {}, rspec: {}, exec_tool: :rspec) }

      # This is.. awkward. But the execcer doesn't actually allow anything after it to _run_ in
      # reality, because when it `exec`s, the running code is replaced (or if it's skipping, it
      # calls Kernel.exit). To emulate that behavior in the specs, without actually performing
      # exit/exec, we're going to have it raise a special error, and rescue that error.
      let(:exec_error_class) { Class.new(StandardError) }
      let(:exec_called) { exec_error_class.new("because the rest of the entrypoint shouldn't run") }
      before { allow(execcer).to receive(:exec!).and_raise(exec_called) }

      let(:rescued_execute) do
        execute
      rescue exec_error_class
        nil
      end

      it "invokes the execcer correctly" do
        rescued_execute

        expect(QuietQuality::Executors::Execcer).to have_received(:new).with(
          tool_options: instance_of(QuietQuality::Config::ToolOptions),
          changed_files: changed_files
        )
        expect(execcer).to have_received(:exec!)
      end

      it "does not invoke the executor" do
        rescued_execute
        expect(executor).not_to have_received(:execute!)
      end

      it "logs as expected" do
        rescued_execute
        expect_debug("Complete Options object:", data: options.to_h)
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
