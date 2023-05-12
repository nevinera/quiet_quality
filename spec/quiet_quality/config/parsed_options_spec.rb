RSpec.describe QuietQuality::Config::ParsedOptions do
  subject(:parsed_options) { described_class.new }

  it { is_expected.to respond_to(:tools) }
  it { is_expected.to respond_to(:tools=) }
  it { is_expected.to respond_to(:help_text) }
  it { is_expected.to respond_to(:help_text=) }

  describe "#helping?" do
    subject(:helping?) { parsed_options.helping? }

    context "when helping is not set" do
      it { is_expected.to be_falsey }
    end

    context "when helping is set" do
      before { parsed_options.helping = true }
      it { is_expected.to be_truthy }
    end
  end

  describe "a global option" do
    it "is nil until set" do
      expect(parsed_options.global_option(:foo)).to be_nil
      expect(parsed_options.global_option(:bar)).to be_nil
    end

    it "can be set and then retrieved" do
      expect { parsed_options.set_global_option(:foo, :bar) }
        .to change { parsed_options.global_option(:foo) }
        .from(nil).to(:bar)
    end

    it "can be set multiple times" do
      parsed_options.set_global_option(:foo, :bar)
      parsed_options.set_global_option(:foo, :baz)
      expect(parsed_options.global_option(:foo)).to eq(:baz)
    end

    it "can be set and retrieved with strings or symbols" do
      parsed_options.set_global_option("foo1", "bar1")
      expect(parsed_options.global_option(:foo1)).to eq("bar1")

      parsed_options.set_global_option(:foo2, "bar2")
      expect(parsed_options.global_option("foo2")).to eq("bar2")
    end

    it "can store and retrieve falsey values" do
      parsed_options.set_global_option(:foo, false)
      expect(parsed_options.global_option(:foo)).to eq(false)
    end
  end

  describe "a tool option" do
    it "is nil until set" do
      expect(parsed_options.tool_option(:spade, :foo)).to be_nil
      expect(parsed_options.tool_option(:hammer, :bar)).to be_nil
    end

    it "can be set and then retrieved" do
      parsed_options.set_tool_option(:spade, :foo, true)
      expect(parsed_options.tool_option(:spade, :foo)).to eq(true)
    end

    it "can be set multiple times" do
      parsed_options.set_tool_option(:spade, :foo, :bar)
      parsed_options.set_tool_option(:spade, :foo, :baz)
      expect(parsed_options.tool_option(:spade, :foo)).to eq(:baz)
    end

    it "can be set with strings and then retrieved with symbols" do
      parsed_options.set_tool_option("spade", "foo1", "bar1")
      expect(parsed_options.tool_option(:spade, :foo1)).to eq("bar1")

      parsed_options.set_tool_option(:spade, :foo1, "bar2")
      expect(parsed_options.tool_option("spade", "foo1")).to eq("bar2")
    end

    it "can store and retrieve falsey values" do
      parsed_options.set_tool_option(:spade, :foo, false)
      expect(parsed_options.tool_option(:spade, :foo)).to eq(false)
    end

    it "can be set differently for different tools" do
      parsed_options.set_tool_option(:spade, :foo, true)
      parsed_options.set_tool_option(:hammer, :foo, false)
      expect(parsed_options.tool_option(:spade, :foo)).to eq(true)
      expect(parsed_options.tool_option(:hammer, :foo)).to eq(false)
    end

    it "is not affected by a matching global option" do
      parsed_options.set_tool_option(:spade, :foo, true)
      parsed_options.set_global_option(:foo, false)
      expect(parsed_options.tool_option(:spade, :foo)).to eq(true)
    end
  end
end
