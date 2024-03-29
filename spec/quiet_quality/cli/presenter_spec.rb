RSpec.describe QuietQuality::Cli::Presenter do
  let(:stream) { instance_double(IO, puts: nil) }

  let(:level) { nil }
  let(:colorize) { false }
  let(:message_format) { nil }
  let(:options) { build_options(colorize: colorize, logging: level, message_format: message_format) }

  let(:rspec_outcome) { build_success(:rspec, "rspec output", "rspec logging") }
  let(:haml_lint_outcome) { build_failure(:haml_lint, "haml_lint output", "haml_lint logging") }
  let(:outcomes) { [rspec_outcome, haml_lint_outcome] }

  let(:message_1) { generate_message(path: "foo.rb", body: "foo \n  body", start_line: 55, stop_line: 55, rule: "foorule", tool_name: :ai_fixes_ur_code) }
  let(:message_2) { generate_message(path: "bar.rb", body: "barbody" + "x" * 200, start_line: 8, stop_line: 14, rule: "barule", tool_name: :sudo_make_me_a_sandwhich) }
  let(:messages) { QuietQuality::Messages.new([message_1, message_2]) }

  subject(:presenter) { described_class.new(stream: stream, options: options, outcomes: outcomes, messages: messages) }

  describe "#log_results" do
    subject(:log_results) { presenter.log_results }

    context "when logging level = :quiet" do
      let(:level) { :quiet }

      it "doesn't write _anything_ to the logger" do
        log_results
        expect(stream).not_to have_received(:puts)
      end
    end

    context "when logging level = light" do
      let(:level) { :light }

      context "with colorization disabled" do
        let(:colorize) { false }

        it "writes a one-line output" do
          log_results
          expect(stream).to have_received(:puts).once
            .with("2 tools executed: 1 passed, 1 failed (haml_lint)")
        end
      end

      context "with colorization enabled" do
        let(:colorize) { true }

        it "writes a one-line output" do
          log_results
          expect(stream).to have_received(:puts).once
            .with("2 tools executed: 1 passed, 1 failed\e[31m (haml_lint)\e[0m")
        end
      end
    end

    context "when logging normally" do
      let(:level) { nil }

      context "with colorization disabled" do
        let(:colorize) { false }

        it "writes standard output" do
          log_results
          expect(stream).to have_received(:puts).with("--- Passed: rspec").ordered
          expect(stream).to have_received(:puts).with("--- Failed: haml_lint").ordered
          expect(stream).to have_received(:puts).with("\n\n2 messages:").ordered
          expect(stream).to have_received(:puts).with("ai_fixes_ur_code  foo.rb:55  [foorule]  foo\\nbody").ordered
          expect(stream).to have_received(:puts).with("sudo_make_me_a_sandwhich  bar.rb:8-14  [barule]  barbody" + "x" * 113).ordered
        end
      end

      context "with colorization enabled" do
        let(:colorize) { true }

        it "writes standard output" do
          log_results
          expect(stream).to have_received(:puts).with("--- \e[32mPassed: rspec\e[0m").ordered
          expect(stream).to have_received(:puts).with("--- \e[31mFailed: haml_lint\e[0m").ordered
          expect(stream).to have_received(:puts).with("\n\n2 messages:").ordered
          expect(stream).to have_received(:puts).with("\e[33mai_fixes_ur_code\e[0m  foo.rb:55  [\e[33mfoorule\e[0m]  foo\\nbody").ordered
          expect(stream).to have_received(:puts).with("\e[33msudo_make_me_a_sandwhich\e[0m  bar.rb:8-14  [\e[33mbarule\e[0m]  barbody" + "x" * 113).ordered
        end
      end

      context "with a message-format supplied" do
        let(:message_format) { "%5tool|%5path|%r7lines|%mcyan5rule" }

        it "writes standard output with formatted messages" do
          log_results
          expect(stream).to have_received(:puts).with("--- Passed: rspec").ordered
          expect(stream).to have_received(:puts).with("--- Failed: haml_lint").ordered
          expect(stream).to have_received(:puts).with("\n\n2 messages:").ordered
          expect(stream).to have_received(:puts).with("ai_f…|foo.…|     55|\e[96mfo…le\e[0m")
          expect(stream).to have_received(:puts).with("sudo…|bar.…|   8-14|\e[96mba…le\e[0m")
        end
      end
    end
  end
end
