RSpec.describe QuietQuality::Colorize do
  describe ".colorize" do
    def self.it_colorizes(text, with:, as:)
      it "colors text #{with} properly" do
        expect(described_class.colorize(text, color: with)).to eq(as)
      end
    end

    it_colorizes "hello", with: :red, as: "\e[31mhello\e[0m"
    it_colorizes "hello", with: :green, as: "\e[32mhello\e[0m"
    it_colorizes "hello", with: "yellow", as: "\e[33mhello\e[0m"
    it_colorizes "hello", with: "light_blue", as: "\e[94mhello\e[0m"
    it_colorizes "hello", with: :light_cyan, as: "\e[96mhello\e[0m"

    it "raises an ArgumentError for an unrecognized color" do
      expect { described_class.colorize("hello", color: :tangerine) }
        .to raise_error(ArgumentError, /Unrecognized color 'tangerine'/)
    end
  end
end
