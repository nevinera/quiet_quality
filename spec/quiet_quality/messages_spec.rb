RSpec.describe QuietQuality::Messages do
  let(:m1_data) { {path: "/foo/1", body: "body1", start_line: 1, level: "high", tool_name: "baz"} }
  let(:m2_data) { {path: "/foo/2", body: "body2", start_line: 2, stop_line: 5, tool_name: "qux"} }
  let(:m1) { QuietQuality::Message.load(m1_data) }
  let(:m2) { QuietQuality::Message.load(m2_data) }
  let(:supplied_messages) { [m1, m2] }
  subject(:messages) { described_class.new(supplied_messages) }

  describe ".load_data" do
    let(:data) { [m1_data, m2_data] }
    subject(:loaded_data) { described_class.load_data(data) }
    it { is_expected.to be_a(described_class) }

    it "includes the expected messages" do
      expect(loaded_data.all.first.body).to eq("body1")
      expect(loaded_data.all.last.body).to eq("body2")
    end
  end

  describe ".load_json" do
    let(:json) do
      <<~JSON
        [
          {"path": "/foo/1", "body": "body1", "start_line": 1, "level": "high", "tool_name": "baz"},
          {"path": "/foo/2", "body": "body2", "start_line": 2, "stop_line": 5, "tool_name": "qux"}
        ]
      JSON
    end

    subject(:loaded_json) { described_class.load_json(json) }
    it { is_expected.to be_a(described_class) }

    it "includes the expected messages" do
      expect(loaded_json.all.first.body).to eq("body1")
      expect(loaded_json.all.last.body).to eq("body2")
    end
  end

  describe ".load_yaml" do
    let(:yaml) do
      <<~YAML
        ---
        - path: "/foo/1"
          body: body1
          start_line: 1
          level: high
          tool_name: baz
        - path: "/foo/2"
          body: body2
          start_line: 2
          stop_line: 5
          tool_name: qux
      YAML
    end
    subject(:loaded_yaml) { described_class.load_yaml(yaml) }
    it { is_expected.to be_a(described_class) }

    it "includes the expected messages" do
      expect(loaded_yaml.all.first.body).to eq("body1")
      expect(loaded_yaml.all.last.body).to eq("body2")
    end
  end

  describe "#to_hashes" do
    subject(:to_hashes) { messages.to_hashes }

    it "produces an array of two hashes" do
      expect(to_hashes).to be_an(Array)
      expect(to_hashes.length).to eq(2)
      to_hashes.each { |h| expect(h).to be_a(Hash) }
    end

    it "includes the expected data in each" do
      expect(to_hashes).to eq([
        {"path" => "/foo/1", "body" => "body1", "start_line" => 1, "level" => "high", "tool_name" => "baz"},
        {"path" => "/foo/2", "body" => "body2", "start_line" => 2, "stop_line" => 5, "tool_name" => "qux"}
      ])
    end
  end

  describe "#to_json" do
    subject(:to_json) { messages.to_json }
    it { is_expected.to be_a(String) }

    it "produces json that parses back to the original message data" do
      expect(JSON.parse(to_json)).to eq(messages.to_hashes)
    end

    it "produces compact json" do
      expect(to_json).not_to include("\n")
    end

    context "with pretty supplied as true" do
      subject(:to_json) { messages.to_json(pretty: true) }

      it "produces json that parses back to the original message data" do
        expect(JSON.parse(to_json)).to eq(messages.to_hashes)
      end

      it "produces multiline (readable) json output" do
        expect(to_json).to include("\n")
      end
    end
  end

  describe "#to_yaml" do
    subject(:to_yaml) { messages.to_yaml }
    it { is_expected.to be_a(String) }

    it "produces yaml containing the expected data" do
      expect(YAML.safe_load(to_yaml)).to eq(messages.to_hashes)
    end
  end

  describe "#each" do
    context "with a block" do
      it "calls the block with each message" do
        visited = []
        messages.each { |m| visited << m }
        expect(visited).to eq([m1, m2])
      end
    end

    context "without a block" do
      it "returns an enumerator that iterates the messages" do
        enumerator = messages.each
        expect(enumerator).to be_an(Enumerator)
        expect(enumerator.count).to eq(2)
      end
    end
  end

  describe "#all" do
    subject(:all) { messages.all }
    it { is_expected.to be_an(Array) }
    it { is_expected.to contain_exactly(m1, m2) }
  end

  describe "#empty?" do
    subject(:empty?) { messages.empty? }

    context "when there are no messages" do
      let(:supplied_messages) { [] }
      it { is_expected.to be_truthy }
    end

    context "when there are some messages" do
      before { expect(supplied_messages).not_to be_empty }
      it { is_expected.to be_falsey }
    end
  end

  describe "Enumerable" do
    it { is_expected.to respond_to(:all) }
    it { is_expected.to respond_to(:map) }
    it { is_expected.to respond_to(:first) }
    it { is_expected.to respond_to(:count) }
    it { is_expected.to respond_to(:select) }
  end
end
