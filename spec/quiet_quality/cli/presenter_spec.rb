RSpec.describe QuietQuality::Cli::Presenter do
  let(:logger) { instance_double(QuietQuality::Logger, puts: nil) }
  let(:level) { nil }
  let(:logging) { QuietQuality::Config::Logging.new(level: level) }

  let(:rspec_outcome) { build_success(:rspec, "rspec output", "rspec logging") }
  let(:haml_lint_outcome) { build_failure(:haml_lint, "haml_lint output", "haml_lint logging") }
  let(:outcomes) { [rspec_outcome, haml_lint_outcome] }

  let(:message_1) { generate_message(path: "foo.rb", body: "foo \n  body", start_line: 55, stop_line: 55, rule: "foorule") }
  let(:message_2) { generate_message(path: "bar.rb", body: "barbody" + "x" * 200, start_line: 8, stop_line: 14, rule: "barule") }
  let(:messages) { QuietQuality::Messages.new([message_1, message_2]) }

  subject(:presenter) { described_class.new(logger: logger, logging: logging, outcomes: outcomes, messages: messages) }

  describe "#log_results" do
    subject(:log_results) { presenter.log_results }

    context "when logging.quiet?" do
      let(:level) { QuietQuality::Config::Logging::QUIET }

      it "doesn't write _anything_ to the logger" do
        log_results
        expect(logger).not_to have_received(:puts)
      end
    end

    context "when logging.light?" do
      let(:level) { QuietQuality::Config::Logging::LIGHT }

      it "writes a one-line output" do
        log_results
        expect(logger).to have_received(:puts).once
          .with("2 tools executed: 1 passed, 1 failed (haml_lint)")
      end
    end

    context "when logging normally" do
      let(:level) { nil }

      it "writes standard output" do
        log_results
        expect(logger).to have_received(:puts).with("--- Passed: rspec").ordered
        expect(logger).to have_received(:puts).with("--- Failed: haml_lint").ordered
        expect(logger).to have_received(:puts).with("\n\n2 messages:").ordered
        expect(logger).to have_received(:puts).with("  foo.rb:55  [foorule]  foo\\nbody").ordered
        expect(logger).to have_received(:puts).with("  bar.rb:8-14  [barule]  barbody" + "x" * 113).ordered
      end
    end
  end
end
