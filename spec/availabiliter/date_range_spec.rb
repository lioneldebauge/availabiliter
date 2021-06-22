# frozen_string_literal: true

require "availabiliter/date_range"

RSpec.describe Availabiliter::DateRange do
  let(:date_range) { described_class.new(Date.new(2020, 1, 1), Date.new(2020, 1, 3)) }

  describe "#new" do
    subject(:new) { described_class.new(start_date, end_date) }

    context "when range start_date and end_date are dates in chronological order" do
      let(:start_date) { Date.new(2000, 1, 1) }
      let(:end_date) { Date.new(2000, 1, 31) }

      it { is_expected.to be_instance_of(described_class) }
      it { is_expected.to have_attributes(start_date: start_date, end_date: end_date) }
    end

    context "when range has a start_date and no end_date" do
      let(:start_date) { Date.new(2000, 1, 1) }
      let(:end_date) { nil }

      it { is_expected.to be_instance_of(described_class) }
      it { is_expected.to have_attributes(start_date: start_date, end_date: end_date) }
    end

    context "when the end_date is before the start_date" do
      let(:start_date) { Date.new(2000, 1, 31) }
      let(:end_date) { Date.new(2000, 1, 1) }

      it "raises an error" do
        expect { subject }.to raise_error(ArgumentError, "bad value for DateRange")
      end
    end

    context "when the range start and end are not dates" do
      let(:start_date) { 1 }
      let(:end_date) { 10 }
      it "raises an error" do
        expect { subject }.to raise_error(ArgumentError, "bad value for DateRange")
      end
    end
  end

  describe "#independent?" do
    subject(:independent?) { date_range.independent?(other_date_range) }

    let(:date_range) { described_class.new(date_range_start, date_range_end) }
    let(:date_range_start) { Date.new(2020, 1, 1) }
    let(:date_range_end) { Date.new(2020, 1, 3) }

    context "when there is no other date_range" do
      let(:other_date_range) { nil }

      it { is_expected.to eq true }
    end

    context "when it doesn't overlap or is not adjacent with the other date_range" do
      let(:other_date_range) { described_class.new(date_range_end + 2, nil) }

      it { is_expected.to eq true }
    end

    context "when it overlaps with the other date range" do
      let(:other_date_range) { described_class.new(date_range_start + 2, date_range_end + 2) }

      it { is_expected.to eq false }
    end

    context "when it is adjacent with the other date_range" do
      let(:other_date_range) { described_class.new(date_range_end + 1, date_range_end + 10) }

      it { is_expected.to eq false }
    end
  end

  describe "#tomorrow" do
    subject(:tomorrow) { date_range.tomorrow }

    let(:date_range) { described_class.new(Date.new(2020, 1, 1), end_date) }

    context "when the end_date is nil" do
      let(:end_date) { nil }

      it "returns nil" do
        expect(tomorrow).to eq nil
      end
    end

    context "when the end_date is not nil" do
      let(:end_date) { Date.new(2020, 3, 1) }

      it "returns the day after the end_date" do
        expect(tomorrow).to eq end_date + 1
      end
    end
  end

  describe "#yesterday" do
    subject(:tomorrow) { date_range.yesterday }

    let(:date_range) { described_class.new(Date.new(2020, 1, 1), nil) }

    it "returns the day before the start_date" do
      expect(tomorrow).to eq Date.new(2019, 12, 31)
    end
  end

  describe "#overlaps?" do
    subject(:overlaps?) { date_range.overlaps?(other_date_range) }

    let(:date_range) { described_class.new(start_date, end_date) }
    let(:start_date) { Date.new(2000, 1, 1) }
    let(:end_date) { Date.new(2000, 1, 3) }

    context "when date_range covers the other date_range start_date" do
      let(:other_date_range) { described_class.new(start_date + 1, nil) }

      it { is_expected.to be true }
    end

    context "when the other date_range covers the date_range start_date" do
      let(:other_date_range) { described_class.new(start_date - 1, nil) }

      it { is_expected.to be true }
    end

    context "when neither of date ranges cover each other start_date" do
      let(:other_date_range) { described_class.new(end_date + 1, nil) }

      it { is_expected.to be false }
    end
  end

  describe "#adjacent?" do
    subject(:adjacent?) { date_range.adjacent?(other_date_range) }

    let(:date_range) { described_class.new(date_range_start, date_range_end) }
    let(:other_date_range) { described_class.new(other_date_range_start, other_date_range_end) }
    let(:date_range_start) { Date.new(2000, 1, 1) }

    context "when the date_range_end is nil" do
      let(:date_range_end) { nil }

      context "when other_date_range end is yesterday" do
        let(:other_date_range_start) { other_date_range_end.prev_day }
        let(:other_date_range_end) { date_range.yesterday }

        it { is_expected.to be true }
      end

      context "when other_date_range end is not yesterday" do
        let(:other_date_range_start) { date_range_start - 1 }
        let(:other_date_range_end) { nil }

        it { is_expected.to be false }
      end
    end

    context "when the range end is not nil" do
      let(:date_range_end) { date_range_start + 1 }

      context "when other_date_range end is yesterday" do
        let(:other_date_range_start) { other_date_range_end.prev_day }
        let(:other_date_range_end) { date_range.yesterday }

        it { is_expected.to be true }
      end

      context "when other_date_range start is tomorrow" do
        let(:other_date_range_start) { date_range.tomorrow }
        let(:other_date_range_end) { nil }

        it { is_expected.to be true }
      end

      context "when other_date_range start is not tomorrow and its end is not yesterday" do
        let(:other_date_range_start) { date_range.tomorrow.prev_day }
        let(:other_date_range_end) { nil }

        it { is_expected.to be false }
      end
    end
  end

  describe "#next_availability" do
    subject(:next_availability) { date_range.next_availability(next_date_range) }

    let(:date_range) { described_class.new(Date.new(2020, 1, 1), date_range_end) }
    let(:date_range_end) { Date.new(2020, 2, 1) }
    let(:next_date_range) { described_class.new(next_date_range_start, Date.new(2020, 4, 1)) }
    let(:next_date_range_start) { Date.new(2020, 3, 1) }

    context "when the end_date is nil" do
      let(:date_range_end) { nil }

      it { is_expected.to be nil }
    end

    context "when the end_date is present" do
      context "when next_date_range is nil" do
        let(:next_date_range) { nil }
        let(:expected_start) { date_range_end.next_day }

        it "returns a Range starting tomorrow with no end_date" do
          expect(next_availability).to eq expected_start..
        end
      end

      context "when date_range is not independent from the next_date_range" do
        let(:date_range_end) { Date.new(2020, 2, 1) }
        let(:next_date_range_start) { date_range_end }

        it { is_expected.to eq nil }
      end

      context "when next_date_range is present and date_range is independent " do
        let(:next_date_range_start) { Date.new(2020, 3, 1) }

        it "returns a Range starting tomorrow and ending before next_date_range start" do
          expect(next_availability).to eq date_range_end.next_day..next_date_range.yesterday
        end
      end
    end
  end

  describe "#furthest" do
    subject(:furthest) { date_range.furthest(other_date_range) }

    let(:date_range) { described_class.new(start_date, end_date) }
    let(:other_date_range) { described_class.new(other_date_range_start, other_date_range_end) }
    let(:start_date) { Date.new(2000, 1, 1) }
    let(:end_date) { Date.new(2000, 2, 1) }
    let(:other_date_range_start) { Date.new(2000, 3, 1) }
    let(:other_date_range_end) { Date.new(2000, 4, 1) }

    context "when end_date is nil" do
      let(:end_date) { nil }

      it "returns the date_range" do
        expect(furthest).to eq date_range
      end
    end

    context "when other date_range is nil" do
      let(:other_date_range) { nil }

      it "returns the date_range" do
        expect(furthest).to eq date_range
      end
    end

    context "when other date_range end_date is nil" do
      let(:other_date_range_end) { nil }

      it "returns the other date_range" do
        expect(furthest).to eq other_date_range
      end
    end

    it "returns the date_range with the furthest end_date" do
      expect(furthest).to eq other_date_range
    end
  end
end
