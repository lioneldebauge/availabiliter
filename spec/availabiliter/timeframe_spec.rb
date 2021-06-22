# frozen_string_literal: true

require "availabiliter/timeframe"

RSpec.describe TimeFrame do
  describe "#new" do
    subject(:new) { described_class.new(range_array) }

    let(:range_array) { [latest_range, earliest_range] }
    let(:earliest_range) { Date.new(2000, 1, 1)..Date.new(2000, 3, 1) }
    let(:latest_range) { Date.new(2000, 5, 1)..Date.new(2000, 7, 1) }
    let(:expected_date_ranges) { [date_range1, date_range2] }
    let(:date_range1) { DateRange.new(earliest_range.begin, earliest_range.end) }
    let(:date_range2) { DateRange.new(latest_range.begin, latest_range.end) }

    it "builds an array of date_ranges" do
      expect(subject.date_ranges).to all be_an DateRange
    end

    it "sorts the date_ranges by start_date" do
      expect(subject.date_ranges).to eql expected_date_ranges
    end

    it "sets the start_date to nil by default" do
      expect(subject.start_date).to eq nil
    end

    context "when the start_date is given" do
      subject(:new) { described_class.new(range_array, start_date) }
      let(:start_date) { earliest_range.end.next_day }

      it "removes all ranges ending before the start date" do
        expect(subject.date_ranges).to start_with(latest_range)
      end

      context "when start_date is not a date" do
        let(:start_date) { 1 }

        it "raises an error" do
          expect { subject }.to raise_error ArgumentError
        end
      end
    end

    context "when there are more than one endless range" do
      let(:earliest_range) { Date.new(2000, 1, 1).. }
      let(:latest_range) { Date.new(2000, 5, 1).. }

      it "raises an error" do
        expect { subject }.to raise_error ArgumentError
      end
    end
  end

  describe "#availabilities" do
    subject(:get_availabilities) { timeframe.availabilities }

    let(:timeframe) { described_class.new(range_array, start_date) }
    let(:start_date) { nil }

    context "when there are no date_ranges" do
      let(:range_array) { [] }

      context "when the start_date is present" do
        let(:start_date) { Date.new(1999, 1, 1) }

        it { is_expected.to eq [start_date..] }
      end

      context "when the start_date is absent" do
        let(:start_date) { nil }

        it { is_expected.to eq [nil..nil] }
      end
    end

    context "when there are at least one date_range" do
      let(:range_array) { [range] }
      let(:range) { range_start..range_end }
      let(:range_start) { Date.new(2000, 1, 1) }
      let(:range_end) { Date.new(2000, 3, 1) }

      context "when the start_date is absent" do
        let(:start_date) { nil }

        it "returns the corresponding availabilities starting from the first date_range" do
          expect(get_availabilities).to eq [range_end.next_day..]
        end
      end

      context "when the first date_range starts before the start_date" do
        let(:start_date) { range_start - 10 }

        it "returns the availabilities array with a first element starting the day after the start_date" do
          expect(get_availabilities).to eq [start_date..range_start.prev_day, range_end.next_day..]
        end
      end

      context "when the first date_range starts at the same date or after the start_date" do
        let(:start_date) { range_start }

        it "returns the corresponding availabilities starting after the first date_range" do
          expect(get_availabilities).to eq [range_end.next_day..]
        end
      end
    end
  end
end
