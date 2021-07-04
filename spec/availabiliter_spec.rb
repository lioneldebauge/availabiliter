# frozen_string_literal: true

RSpec.describe Availabiliter do
  it "has a version number" do
    expect(Availabiliter::VERSION).not_to be nil
  end

  # End to end test to sleep better at night
  describe "#availabilities" do
    subject(:subject) { described_class.get_availabilities(range_array, timeframe_start) }

    let(:range_array) { [range1, range2, range3] }
    let(:range1) { Date.new(1999, 1, 2)..Date.new(1999, 5, 1) }
    let(:range2) { Date.new(2000, 1, 1)..Date.new(2000, 2, 1) }
    let(:range3) { Date.new(2000, 3, 1)..nil }
    let(:timeframe_start) { nil }

    context "when no time frame start is given" do
      context "when the last date_range has no end date" do
        let(:range1) { Date.new(2000, 1, 1)..Date.new(2000, 2, 1) }
        let(:range2) { Date.new(2001, 1, 2).. }
        let(:range_array) { [range1, range2] }

        it { expect(subject).to eq [Date.new(2001, 2, 2)..Date.new(2001, 1, 1)] }
      end

      context "when the last date_range has an end date" do
        let(:range1) { Date.new(2000, 1, 1)..Date.new(2000, 2, 1) }
        let(:range2) { Date.new(2001, 1, 2)..Date.new(2001, 3, 1) }
        let(:range_array) { [range1, range2] }

        it { expect(subject).to eq [Date.new(2000, 2, 2)..Date.new(2001, 1, 1), Date.new(2001, 3, 2)..] }
      end

      context "when two date_range overlap between each other" do
        context "when the overlap is partial" do
          let(:range1) { Date.new(2000, 1, 1)..Date.new(2001, 1, 1) }
          let(:range2) { Date.new(2000, 6, 1)..Date.new(2001, 6, 1) }
          let(:range_array) { [range1, range2] }

          it { expect(subject).to eq [Date.new(2001, 6, 2)..] }
        end

        context "when the first range totally overlap the last range" do
          let(:range_array) { [range1, range2] }
          let(:range1) { Date.new(1999, 1, 2)..Date.new(1999, 5, 1) }
          let(:range2) { Date.new(1999, 2, 1)..Date.new(1999, 3, 1) }
          let(:timeframe_start) { nil }

          it { is_expected.to eq [Date.new(1999, 5, 2)..] }
        end

        context "when the last range totally overlap the first range" do
          let(:range1) { Date.new(2001, 1, 1)..Date.new(2003, 1, 1) }
          let(:range2) { Date.new(2000, 6, 1)..Date.new(2001, 6, 1) }
          let(:range_array) { [range1, range2] }

          it { is_expected.to eq [Date.new(2003, 1, 2)..] }
        end
      end

      context "when two date_range are consecutive" do
        let(:range1) { Date.new(2000, 1, 1)..Date.new(2001, 1, 1) }
        let(:range2) { Date.new(2001, 1, 1)..Date.new(2002, 1, 1) }
        let(:range_array) { [range1, range2] }

        it { is_expected.to eq [Date.new(2002, 1, 2)..] }
      end
    end
  end
end
