RSpec.describe QuietQuality::AnnotationLocator do
  let(:foo_file) { QuietQuality::ChangedFile.new(path: "path/foo.rb", lines: [1, 2, 3, 5, 10]) }
  let(:bar_file) { QuietQuality::ChangedFile.new(path: "path/bar.rb", lines: [5, 6, 7, 14, 15]) }
  let(:changed_files) { QuietQuality::ChangedFiles.new([foo_file, bar_file]) }
  subject(:locator) { described_class.new(changed_files: changed_files) }

  def build_message(path, body, start, stop=nil)
    QuietQuality::Message.new(path: path, body: body, start_line: start, stop_line: stop)
  end

  describe "#update!" do
    subject(:update!) { locator.update!(message) }

    context "for a message that doesn't match a changed file" do
      let(:message) { build_message("path/baz.rb", "yes!", 1, 50) }
      it { is_expected.to be_nil }

      it "doesn't update annotated_line from nil" do
        expect { update! }.not_to change { message.annotated_line }.from(nil)
      end
    end

    context "for a message that doesn't match a changed line" do
      let(:message) { build_message(foo_file.path, "yes!", 6, 8) }
      it { is_expected.to be_nil }

      it "doesn't update annotated_line from nil" do
        expect { update! }.not_to change { message.annotated_line }.from(nil)
      end
    end

    context "for a message that matches a single changed line" do
      let(:message) { build_message(foo_file.path, "yes!", 5, 5) }
      it { is_expected.to eq(5) }

      it "updates annotated_line to match" do
        expect { update! }.to change { message.annotated_line }.from(nil).to(5)
      end
    end

    context "for a message that matches several changed lines" do
      let(:message) { build_message(foo_file.path, "yes!", 1, 3) }
      it { is_expected.to eq(3) }

      it "updates annotated_line to match" do
        expect { update! }.to change { message.annotated_line }.from(nil).to(3)
      end

      context "including more lines than were changed" do
        let(:message) { build_message(bar_file.path, "no?", 2, 11) }
        it { is_expected.to eq(7) }

        it "updates annotated_line to match" do
          expect { update! }.to change { message.annotated_line }.from(nil).to(7)
        end
      end
    end
  end
end
