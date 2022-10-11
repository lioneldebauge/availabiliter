RSpec.describe Availabiliter::TimeSlotCollection do
  let(:default_options) { { minimum_availability_start: -Float::INFINITY, maximum_availability_end: Float::INFINITY } }

  describe "#initialize" do
    let(:time_slot_collection) { described_class.new(**default_options.merge(arguments)) }
    let(:last_time_slot) { time_slot_collection.to_a.last }
    let(:arguments) { { time_slots: time_slots } }
    let(:time_slots) do
      [
        Availabiliter::TimeSlot.new(starting_time: 100, ending_time: 200),
        Availabiliter::TimeSlot.new(starting_time: 10, ending_time: 40),
        Availabiliter::TimeSlot.new(starting_time: 20, ending_time: 30)
      ]
    end

    it "returns a collection with a time slot acting as boundary as first element" do
      expect(time_slot_collection.first).to have_attributes(class: Availabiliter::TimeSlot, boundary: true)
    end

    it "returns a collection with a time slot acting as boundary instance as last element " do
      expect(last_time_slot).to have_attributes(class: Availabiliter::TimeSlot, boundary: true)
    end

    it "returns a collection of timeslots between the start and end boundaries" do
      expect(time_slot_collection.to_a[1..]).eql?(time_slots.sort_by(&:starting_time))
    end

    context "when there is a minimum availability start" do
      let(:arguments) { { time_slots: time_slots, minimum_availability_start: minimum_availability_start } }
      let(:minimum_availability_start) { 22_232 }

      it "the start boundary ending time is the previous second before the minimum availability start" do
        expect(time_slot_collection.first).to have_attributes(ending_time: minimum_availability_start - 1)
      end
    end

    context "when there is no minimum availability start" do
      let(:arguments) { { time_slots: time_slots } }

      it "the start boundary ending time is -infinity" do
        expect(time_slot_collection.first).to have_attributes(ending_time: -Float::INFINITY)
      end
    end

    context "when there is a maximum availability end" do
      let(:arguments) { { time_slots: time_slots, maximum_availability_end: maximum_availability_end } }
      let(:maximum_availability_end) { 22_232_565 }

      it "the end boundary starting time is the next second after the maximum availability end" do
        expect(time_slot_collection.to_a.last).to have_attributes(starting_time: maximum_availability_end + 1)
      end
    end

    context "when there is no maximum end" do
      let(:arguments) { { time_slots: time_slots } }

      it "the end boundary starting time is +infinity" do
        expect(last_time_slot).to have_attributes(starting_time: Float::INFINITY)
      end
    end
  end

  describe "#availabilities" do
    subject(:availabilities) { time_slot_collection.availabilities }

    let(:time_slot_collection) { described_class.new(**default_options.merge(arguments)) }
    let(:arguments) { { time_slots: time_slots } }
    let(:time_slots) { [first_time_slot, last_time_slot] }
    let(:first_time_slot) { Availabiliter::TimeSlot.new(starting_time: 100, ending_time: 200) }
    let(:last_time_slot) { Availabiliter::TimeSlot.new(starting_time: 300, ending_time: 400) }

    context "when the time slots overlap" do
      let(:time_slot) { Availabiliter::TimeSlot.new(starting_time: 100, ending_time: 200) }
      let(:overlaping_time_slot1) { Availabiliter::TimeSlot.new(starting_time: 98, ending_time: time_slot.starting_time) }
      let(:overlaping_time_slot2) { Availabiliter::TimeSlot.new(starting_time: time_slot.starting_time, ending_time: time_slot.ending_time) }
      let(:overlaping_time_slot3) { Availabiliter::TimeSlot.new(starting_time: time_slot.ending_time, ending_time: 201) }
      let(:time_slots) { [time_slot, overlaping_time_slot1, overlaping_time_slot2, overlaping_time_slot3] }
      let(:expected_availabilities) { [[-Float::INFINITY, 97], [202, Float::INFINITY]] }

      it "returns the correct availabilities" do
        expect(availabilities).to eq expected_availabilities
      end
    end

    context "when the time slots are adjacent" do
      let(:time_slot) { Availabiliter::TimeSlot.new(starting_time: 100, ending_time: 200) }
      let(:adjacent_time_slot1) { Availabiliter::TimeSlot.new(starting_time: time_slot.starting_time - 10, ending_time: time_slot.starting_time - 1) }
      let(:adjacent_time_slot2) { Availabiliter::TimeSlot.new(starting_time: time_slot.ending_time + 1, ending_time: time_slot.ending_time + 10) }
      let(:time_slots) { [time_slot, adjacent_time_slot1, adjacent_time_slot2] }
      let(:expected_availabilities) { [[-Float::INFINITY, 89], [211, Float::INFINITY]] }

      it "returns the correct availabilities" do
        expect(availabilities).to eq expected_availabilities
      end
    end

    context "when collection is given a minimum availability start" do
      let(:arguments) { { time_slots: time_slots, minimum_availability_start: minimum_availability_start } }
      let(:first_availability) { availabilities.first }

      context "when last time slot ends before the minimum availability start" do
        let(:minimum_availability_start) { first_time_slot.ending_time + 10 }

        it "sets the first availability start to be the availability minimum start" do
          expect(first_availability.first).to eq minimum_availability_start
        end
      end

      context "when the first time slot ends after the minimum availability start" do
        let(:minimum_availability_start) { first_time_slot.ending_time - 10 }

        it "sets the first availability start to be the start of the first collection's gap" do
          expect(first_availability.first).to eq first_time_slot.next_second
        end
      end
    end

    context "when collection is given a maximum availability end" do
      let(:arguments) { { time_slots: time_slots, maximum_availability_end: maximum_availability_end } }
      let(:last_availability) { availabilities.last }

      context "when last time slot ends before the maximum availability end" do
        let(:maximum_availability_end) { last_time_slot.ending_time + 10 }

        it "sets the last availability end to be the maximum availability end" do
          expect(last_availability.last).to eq maximum_availability_end
        end
      end

      context "when last time slot ends after the maximum availability end" do
        let(:maximum_availability_end) { last_time_slot.ending_time - 10 }

        it "sets the last availability end to be the end of the last collection's gap" do
          expect(last_availability.last).to eq last_time_slot.previous_second
        end
      end
    end

    context "when the collection is not given a minimum availability start" do
      let(:arguments) { { time_slots: time_slots } }
      let(:first_availability) { availabilities.first }

      context "when first time slot has an infinite start" do
        let(:first_time_slot) { Availabiliter::TimeSlot.new(starting_time: -Float::INFINITY, ending_time: 200) }

        it "sets the first availability start to be first collection's gap start" do
          expect(first_availability.first).to eq first_time_slot.next_second
        end
      end

      context "when first time slot has a finite start" do
        let(:first_time_slot) { Availabiliter::TimeSlot.new(starting_time: 100, ending_time: 200) }

        it "sets the first availability start to be -infinite" do
          expect(first_availability.first).to eq(-Float::INFINITY)
        end

        it "sets the first availability end to be first collection's gap start" do
          expect(first_availability.last).to eq first_time_slot.previous_second
        end
      end
    end

    context "when the collection is not given a maximum availability end" do
      let(:arguments) { { time_slots: time_slots } }
      let(:last_availability) { availabilities.last }

      context "when a time slot has an infinite end" do
        let(:last_time_slot) { Availabiliter::TimeSlot.new(starting_time: 300, ending_time: Float::INFINITY) }

        it "sets the last availability end to be last collection's gap end" do
          expect(last_availability.last).to eq last_time_slot.previous_second
        end
      end

      context "when all time slots have a finite end" do
        let(:last_time_slot) { Availabiliter::TimeSlot.new(starting_time: 300, ending_time: 400) }

        it "sets the last availability end to be infinite" do
          expect(last_availability.last).to eq Float::INFINITY
        end

        it "sets the last availability start to the start of the last gap" do
          expect(last_availability.first).to eq last_time_slot.next_second
        end
      end
    end
  end
end
