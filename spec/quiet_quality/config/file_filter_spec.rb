RSpec.describe QuietQuality::Config::FileFilter do
  subject(:file_filter) { described_class.new(regex: regex_param, excludes: excludes_param) }
  let(:regex_param) { nil }
  let(:excludes_param) { nil }

  describe "#regex" do
    subject(:regex) { file_filter.regex }

    context "when the regex parameter is nil" do
      let(:regex_param) { nil }
      it { is_expected.to be_nil }
    end

    context "when the regex parameter is a simple string" do
      let(:regex_param) { "foo" }
      it { is_expected.to eq(/foo/) }
    end

    context "when the regex parameter is string with regex syntax in it" do
      let(:regex_param) { "[f-g]+oo.*bar" }
      it { is_expected.to eq(/[f-g]+oo.*bar/) }
    end
  end

  describe "#excludes" do
    subject(:excludes) { file_filter.excludes }

    context "when the excludes parameter is nil" do
      let(:excludes_param) { nil }
      it { is_expected.to be_nil }
    end

    context "when the excludes parameter is a simple string" do
      let(:excludes_param) { "foo" }
      it { is_expected.to contain_exactly(/foo/) }
    end

    context "when the excludes parameter is a complex regex string" do
      let(:excludes_param) { "a[b-d]?c*$" }
      it { is_expected.to contain_exactly(/a[b-d]?c*$/) }
    end

    context "when the excludes parameter is an array of simple strings" do
      let(:excludes_param) { ["foo", "bar"] }
      it { is_expected.to contain_exactly(/foo/, /bar/) }
    end

    context "when the excludes parameter is an array of complex regex strings" do
      let(:excludes_param) { ["a[b-d]?c*$", "qq+q?[qQ]*"] }
      it { is_expected.to contain_exactly(/a[b-d]?c*$/, /qq+q?[qQ]*/) }
    end
  end

  describe "#match?" do
    subject(:match?) { file_filter.match?(path) }
    let(:path) { "foo/bar/baz.zam" }

    context "when neither regex nor excludes are supplied" do
      let(:regex_param) { nil }
      let(:excludes_param) { nil }
      it { is_expected.to be_truthy }
    end

    context "when regex is supplied without excludes" do
      let(:regex_param) { "foo" }
      let(:excludes_param) { nil }

      context "when the regex matches the path" do
        let(:path) { "biz/fooba/bam" }
        it { is_expected.to be_truthy }
      end

      context "when the regex does not match the path" do
        let(:path) { "something/else" }
        it { is_expected.to be_falsey }
      end
    end

    context "when excludes are supplied without regex" do
      let(:regex_param) { nil }
      let(:excludes_param) { ["ab+d", "ab+c"] }

      context "when the path matches none of the excludes" do
        let(:path) { "none/of/those" }
        it { is_expected.to be_truthy }
      end

      context "when the path matches one of the excludes" do
        let(:path) { "path/abbbbd/file" }
        it { is_expected.to be_falsey }
      end
    end

    context "when both regex and excludes are supplied" do
      let(:regex_param) { "foo" }
      let(:excludes_param) { ["ab+d", "ab+c"] }

      context "when the path matches neither the regex nor the excludes" do
        let(:path) { "other/path" }
        it { is_expected.to be_falsey }
      end

      context "when the path matches the regex and not the excludes" do
        let(:path) { "path/to/fooba" }
        it { is_expected.to be_truthy }
      end

      context "when the path matches the excludes and the regex" do
        let(:path) { "path/to/fooba/abbbc.zip" }
        it { is_expected.to be_falsey }
      end

      context "when the path matches the excludes and not the regex" do
        let(:path) { "path/to/abbc.txt" }
        it { is_expected.to be_falsey }
      end
    end
  end

  describe "==" do
    let(:ff) { described_class.new(regex: "a", excludes: ["b", "c"]) }
    let(:ff_same) { described_class.new(regex: "a", excludes: ["b", "c"]) }
    let(:ff_different_order) { described_class.new(regex: "a", excludes: ["b", "c"]) }
    let(:ff_different_values) { described_class.new(regex: "b", excludes: ["a", "c"]) }

    specify { expect(ff).to eq(ff_same) }
    specify { expect(ff).to eq(ff_different_order) }
    specify { expect(ff).not_to eq(ff_different_values) }
  end
end
