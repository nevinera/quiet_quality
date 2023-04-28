RSpec.describe QuietQuality::Message do
  subject(:message) { described_class.new(**attributes) }

  let(:attributes) do
    {
      path: path,
      body: body,
      start_line: start_line,
      stop_line: stop_line,
      annotated_line: annotated_line,
      level: level,
      rule: rule
    }.compact
  end

  let(:path) { "/foo/path.rb" }
  let(:body) { "fake message" }
  let(:start_line) { 10 }
  let(:stop_line) { 14 }
  let(:annotated_line) { 12 }
  let(:level) { "serious" }
  let(:rule) { "You Shall Not Pass" }

  it { is_expected.to be_a(QuietQuality::Message) }

  shared_examples "raises a KeyError" do
    it "raises a KeyError" do
      expect { subject }.to raise_error(KeyError)
    end
  end

  shared_examples "required field" do |field_name, binding_name|
    describe "##{field_name}" do
      subject { message.send(field_name) }
      it { is_expected.to eq(send(binding_name)) }

      context "when #{binding_name} isn't supplied" do
        let(binding_name) { nil }
        include_examples "raises a KeyError"
      end
    end
  end

  shared_examples "field with default" do |field_name, options|
    binding_name = options.fetch(:binding_name, field_name)
    default_value = options.fetch(:default_value, nil)
    default_binding = options.fetch(:default_binding, nil)

    describe "##{field_name}" do
      subject { message.send(field_name) }
      it { is_expected.to eq(send(binding_name)) }

      context "when #{binding_name} isn't supplied" do
        let(binding_name) { nil }
        if default_binding
          it { is_expected.to eq(send(default_binding)) }
        else
          it { is_expected.to eq(default_value) }
        end
      end
    end
  end

  include_examples "required field", :path, :path
  include_examples "required field", :body, :body
  include_examples "required field", :start_line, :start_line
  include_examples "field with default", :stop_line, default_binding: :start_line
  include_examples "field with default", :level, default_value: nil
  include_examples "field with default", :rule, default_value: nil

  describe "#annotated_line" do
    subject { message.annotated_line }

    context "when it is set during initialization" do
      let(:annotated_line) { 19 }
      it { is_expected.to eq(19) }
    end

    context "when it is set later" do
      let(:annotated_line) { nil }
      before { message.annotated_line = 44 }
      it { is_expected.to eq(44) }
    end

    context "when it is not set" do
      let(:annotated_line) { nil }

      context "but stop_line is" do
        let(:stop_line) { 28 }
        it { is_expected.to eq(28) }
      end

      context "and neither is stop_line" do
        let(:stop_line) { nil }
        it { is_expected.to eq(start_line) }
      end
    end
  end

  describe "#to_h" do
    subject(:to_h) { message.to_h }

    context "when all values are supplied" do
      it "includes all of those values" do
        expect(to_h.keys).to contain_exactly(
          "path",
          "body",
          "start_line",
          "stop_line",
          "annotated_line",
          "level",
          "rule"
        )
      end
    end

    context "when some optional values are missing" do
      let(:level) { nil }
      let(:stop_line) { nil }

      it "includes only the supplied values" do
        expect(to_h.keys).to contain_exactly(
          "path",
          "body",
          "start_line",
          "annotated_line",
          "rule"
        )
      end
    end
  end
end
