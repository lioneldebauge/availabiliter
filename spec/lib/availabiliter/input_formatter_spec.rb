RSpec.describe Availabiliter::InputFormatter do
  describe "#initialize" do
    subject(:new) { described_class.new(input_array: input_array, time_zone: time_zone) }

    let(:input_array) { [[Date.new(2020, 1, 2), Float::INFINITY]] }
    let(:time_zone) { "+02:00" }

    it { is_expected.to have_attributes(input_array: input_array, time_zone: time_zone) }
  end

  describe "#time_slots" do
    subject(:time_slots) { described_class.new(input_array: input_array, time_zone: time_zone).time_slots }

    let(:time_zone) { "+02:00" }

    context "when a raw time slot input contains Date instance" do
      let(:input_array) { [[start_date, end_date]] }
      let(:start_date) { Date.new(2021, 1, 1) }
      let(:end_date) { Date.new(2021, 12, 31) }

      context "when the given time zone is nil" do
        let(:expected_starting_time) { start_date.to_time.to_i }
        let(:expected_ending_time) { end_date.to_time.to_i }
        let(:time_zone) { nil }

        it "instanciates time slot with corresponding timestamp without specifying any time zone" do
          expect(time_slots).to contain_exactly(have_attributes(class: Availabiliter::TimeSlot, starting_time: expected_starting_time, ending_time: expected_ending_time))
        end
      end

      context "when the given time zone is not nil" do
        let(:expected_starting_time) { Time.new(start_date.year, start_date.month, start_date.day, 0, 0, 0, time_zone).to_i }
        let(:expected_ending_time) { Time.new(end_date.year, end_date.month, end_date.day, 0, 0, 0, time_zone).to_i }
        let(:time_zone) { "+02:00" }

        it "instanciates time slot with corresponding timestamp according to the given time zone" do
          expect(time_slots).to contain_exactly(have_attributes(class: Availabiliter::TimeSlot, starting_time: expected_starting_time, ending_time: expected_ending_time))
        end
      end
    end

    context "when a raw time slot contains Time instance" do
      let(:input_array) { [[starting_time, ending_time]] }
      let(:starting_time) { Time.new(2021, 1, 1) }
      let(:ending_time) { Time.new(2021, 12, 31) }
      let(:expected_starting_time) { starting_time.to_i }
      let(:expected_ending_time) { ending_time.to_i }

      it "instanciates time slot with starting and ending timestamp" do
        expect(time_slots).to contain_exactly(have_attributes(class: Availabiliter::TimeSlot, starting_time: expected_starting_time, ending_time: expected_ending_time))
      end
    end

    context "when raw time slot contains a timestamp" do
      let(:input_array) { [[starting_timestamp, ending_timestamp]] }
      let(:starting_timestamp) { 500_000 }
      let(:ending_timestamp) { 500_001 }

      it "instanciates time slot with the same value" do
        expect(time_slots).to contain_exactly(have_attributes(class: Availabiliter::TimeSlot, starting_time: starting_timestamp, ending_time: ending_timestamp))
      end
    end

    context "when raw time slot contains an infinite value" do
      let(:input_array) { [[infinite_start, infinite_end]] }
      let(:infinite_start) { -Float::INFINITY }
      let(:infinite_end) { Float::INFINITY }

      it "instanciates time slot with the same value" do
        expect(time_slots).to contain_exactly(have_attributes(class: Availabiliter::TimeSlot, starting_time: infinite_start, ending_time: infinite_end))
      end
    end

    context "when a subarray of the input array size is not equal to 2" do
      let(:input_array) { [[1, 2, 3]] }
      it "raises" do
        expect do
          time_slots
        end.to raise_error(Availabiliter::IncorrectInput, "In the array input there is a time slot array which size is different from 2")
      end
    end
  end
end
