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
      rule: rule,
      tool_name: tool_name
    }.compact
  end

  let(:path) { "/foo/path.rb" }
  let(:body) { "fake message" }
  let(:start_line) { 10 }
  let(:stop_line) { 14 }
  let(:annotated_line) { 12 }
  let(:level) { "serious" }
  let(:rule) { "You Shall Not Pass" }
  let(:tool_name) { :one_ring_to_rule_them_all }

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
  include_examples "required field", :tool_name, :tool_name
  include_examples "field with default", :stop_line, default_binding: :start_line
  include_examples "field with default", :level, default_value: nil
  include_examples "field with default", :rule, default_value: nil
  include_examples "field with default", :annotated_line, default_value: nil

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
          "rule",
          "tool_name"
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
          "rule",
          "tool_name"
        )
      end
    end
  end
end
