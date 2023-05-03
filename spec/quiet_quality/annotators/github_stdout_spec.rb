RSpec.describe QuietQuality::Annotators::GithubStdout do
  let(:fake_stdout) { instance_double(IO, puts: nil) }
  subject(:annotator) { described_class.new(output_stream: fake_stdout) }

  describe ".format" do
    let(:message) do
      QuietQuality::Message.new(
        path: "foo/bar.rb",
        body: "My Message",
        start_line: start_line,
        annotated_line: annotated_line,
        rule: rule
      )
    end
    let(:start_line) { 20 }
    let(:annotated_line) { 25 }
    let(:rule) { "MyRule" }
    subject(:formatted_line) { described_class.format(message) }

    context "with annotated_line set" do
      let(:annotated_line) { 25 }
      it { is_expected.to eq("::warning file=foo/bar.rb,line=25,title=MyRule::My Message") }
    end

    context "without annotated_line set" do
      let(:annotated_line) { nil }
      it { is_expected.to eq("::warning file=foo/bar.rb,line=20,title=MyRule::My Message") }
    end

    context "with a rule" do
      let(:rule) { "MyRule" }
      it { is_expected.to eq("::warning file=foo/bar.rb,line=25,title=MyRule::My Message") }
    end

    context "with no rule" do
      let(:rule) { nil }
      it { is_expected.to eq("::warning file=foo/bar.rb,line=25::My Message") }
    end
  end

  describe "#annotate!" do
    let(:m1) { QuietQuality::Message.new(path: "foo.rb", body: "Msg1", start_line: 1) }
    let(:m2) { QuietQuality::Message.new(path: "bar.rb", body: "Msg2", start_line: 2, rule: "Title") }
    let(:m3) { QuietQuality::Message.new(path: "baz.rb", body: "Msg3", start_line: 3, annotated_line: 5) }
    let(:messages) { [m1, m2, m3] }
    subject(:annotate!) { annotator.annotate!(messages) }

    it "writes the expected messages to the output stream" do
      annotate!
      expect(fake_stdout).to have_received(:puts).with("::warning file=foo.rb,line=1::Msg1")
      expect(fake_stdout).to have_received(:puts).with("::warning file=bar.rb,line=2,title=Title::Msg2")
      expect(fake_stdout).to have_received(:puts).with("::warning file=baz.rb,line=5::Msg3")
    end

    context "when given more messages than it can annotate" do
      before { stub_const("QuietQuality::Annotators::GithubStdout::MAX_ANNOTATIONS", 2) }

      it "writes the expected messages to the output stream" do
        annotate!
        expect(fake_stdout).to have_received(:puts).with("::warning file=foo.rb,line=1::Msg1")
        expect(fake_stdout).to have_received(:puts).with("::warning file=bar.rb,line=2,title=Title::Msg2")
        expect(fake_stdout).not_to have_received(:puts).with("::warning file=baz.rb,line=5::Msg3")
      end
    end
  end
end
