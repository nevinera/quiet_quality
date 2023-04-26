RSpec.describe QuietQuality::Messages do
  let(:m1) { QuietQuality::Message.new(path: "/foo/1", body: "body1", start_line: 1, level: "high") }
  let(:m2) { QuietQuality::Message.new(path: "/foo/2", body: "body2", start_line: 2, stop_line: 5) }
  subject(:messages) { described_class.new([m1, m2]) }

  describe "#to_hashes" do
    subject(:to_hashes) { messages.to_hashes }

    it "produces an array of two hashes" do
      expect(to_hashes).to be_an(Array)
      expect(to_hashes.length).to eq(2)
      to_hashes.each { |h| expect(h).to be_a(Hash) }
    end

    it "includes the expected data in each" do
      expect(to_hashes).to eq([
        {"path" => "/foo/1", "body" => "body1", "start_line" => 1, "level" => "high"},
        {"path" => "/foo/2", "body" => "body2", "start_line" => 2, "stop_line" => 5}
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
      expect(YAML.load(to_yaml)).to eq(messages.to_hashes)
    end
  end
end
