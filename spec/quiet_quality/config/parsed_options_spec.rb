RSpec.describe QuietQuality::Config::ParsedOptions do
  subject(:parsed_options) { described_class.new }

  before { stub_const("QuietQuality::Config::ParsedOptions::GLOBAL_OPTIONS", [:foo, :bar].to_set) }
  before { stub_const("QuietQuality::Config::ParsedOptions::TOOL_OPTIONS", [:zam, :zim, :foo].to_set) }

  it { is_expected.to respond_to(:tools) }
  it { is_expected.to respond_to(:tools=) }

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

  describe "#printing_version?" do
    subject(:printing_version?) { parsed_options.printing_version? }

    context "when printing_version is not set" do
      it { is_expected.to be_falsey }
    end

    context "when printing_version is set" do
      before { parsed_options.printing_version = true }
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

    it "cannot be set with an unexpected name" do
      expect { parsed_options.set_global_option(:baz, "val") }
        .to raise_error(described_class::InvalidOptionName)
    end

    it "cannot be fetched with an unexpected name" do
      expect { parsed_options.global_option(:baz) }
        .to raise_error(described_class::InvalidOptionName)
    end

    it "can be set multiple times" do
      parsed_options.set_global_option(:foo, :bar)
      parsed_options.set_global_option(:foo, :baz)
      expect(parsed_options.global_option(:foo)).to eq(:baz)
    end

    it "can be set and retrieved with strings or symbols" do
      parsed_options.set_global_option("foo", "bar1")
      expect(parsed_options.global_option(:foo)).to eq("bar1")

      parsed_options.set_global_option(:bar, "bar2")
      expect(parsed_options.global_option("bar")).to eq("bar2")
    end

    it "can store and retrieve falsey values" do
      parsed_options.set_global_option(:foo, false)
      expect(parsed_options.global_option(:foo)).to eq(false)
    end
  end

  describe "a tool option" do
    it "is nil until set" do
      expect(parsed_options.tool_option(:spade, :zam)).to be_nil
      expect(parsed_options.tool_option(:hammer, :zim)).to be_nil
    end

    it "can be set and then retrieved" do
      parsed_options.set_tool_option(:spade, :zam, true)
      expect(parsed_options.tool_option(:spade, :zam)).to eq(true)
    end

    it "can be set multiple times" do
      parsed_options.set_tool_option(:spade, :zam, :bar)
      parsed_options.set_tool_option(:spade, :zam, :baz)
      expect(parsed_options.tool_option(:spade, :zam)).to eq(:baz)
    end

    it "can be set with strings and then retrieved with symbols" do
      parsed_options.set_tool_option("spade", "zam", "bar1")
      expect(parsed_options.tool_option(:spade, :zam)).to eq("bar1")

      parsed_options.set_tool_option(:spade, :zim, "bar2")
      expect(parsed_options.tool_option("spade", "zim")).to eq("bar2")
    end

    it "can store and retrieve falsey values" do
      parsed_options.set_tool_option(:spade, :zam, false)
      expect(parsed_options.tool_option(:spade, :zam)).to eq(false)
    end

    it "can be set differently for different tools" do
      parsed_options.set_tool_option(:spade, :zam, true)
      parsed_options.set_tool_option(:hammer, :zam, false)
      expect(parsed_options.tool_option(:spade, :zam)).to eq(true)
      expect(parsed_options.tool_option(:hammer, :zam)).to eq(false)
    end

    it "is not affected by a matching global option" do
      parsed_options.set_tool_option(:spade, :foo, true)
      parsed_options.set_global_option(:foo, false)
      expect(parsed_options.tool_option(:spade, :foo)).to eq(true)
    end
  end
end
