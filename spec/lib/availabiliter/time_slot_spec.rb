RSpec.describe Availabiliter::TimeSlot do
  describe "#initialize" do
    subject(:new) { described_class.new(**arguments) }

    let(:arguments) { { starting_time: 1, ending_time: 2 } }

    it { is_expected.to be_a described_class }
    it { is_expected.to have_attributes(starting_time: 1, ending_time: 2, boundary: false) }

    context "when time slot starting time is not greater or equal to its ending time" do
      let(:arguments) { { starting_time: 2, ending_time: 1 } }

      it "raises" do
        expect { new }.to raise_error Availabiliter::IncorrectInput, "A time slot ending time must be equal or greater than its starting time"
      end
    end

    context "when time slot acts as a boundary" do
      let(:arguments) { { starting_time: -Float::INFINITY, ending_time: -Float::INFINITY, boundary: true } }
      it "is referenced as such by a boolean attribute" do
        expect(new.boundary).to be true
      end
    end
  end

  describe "#furthest" do
    subject(:furthest) { time_slot.furthest(other) }

    let(:time_slot) { described_class.new(starting_time: 1, ending_time: 2) }
    let(:other) { described_class.new(starting_time: 1, ending_time: 3) }

    it "returns the time slot with the greatest ending time" do
      expect(furthest).to be other
    end
  end

  describe "#next_second" do
    subject(:next_second) { time_slot.next_second }

    let(:time_slot) { described_class.new(starting_time: 1, ending_time: 2) }
    let(:expected_next_second) { time_slot.ending_time + 1 }

    it "returns the second after the ending time" do
      expect(next_second).to eq expected_next_second
    end
  end

  describe "#previous_second" do
    subject(:previous_second) { time_slot.previous_second }

    let(:time_slot) { described_class.new(starting_time: 100, ending_time: 2000) }
    let(:expected_previous_second) { time_slot.starting_time - 1 }

    it "returns the second after the ending time" do
      expect(previous_second).to eq expected_previous_second
    end
  end

  describe "#dependent?" do
    subject(:dependent?) { time_slot.dependent?(other) }

    let(:time_slot) { described_class.new(starting_time: starting_time, ending_time: ending_time) }
    let(:other) { described_class.new(starting_time: other_starting_time, ending_time: other_ending_time) }
    let(:starting_time) { 100 }
    let(:ending_time) { 200 }

    context "when adjacent to the other time slot" do
      let(:other_starting_time) { starting_time - 50 }
      let(:other_ending_time) { starting_time - 1 }

      it { is_expected.to eq true }
    end

    context "when overlapping the other time slot" do
      let(:other_starting_time) { starting_time }
      let(:other_ending_time) { ending_time }

      it { is_expected.to eq true }
    end

    context "when not overlapping and not adjacent to the other time slot" do
      let(:other_starting_time) { starting_time - 3 }
      let(:other_ending_time) { starting_time - 2 }

      it { is_expected.to eq false }
    end
  end

  describe "#adjacent?" do
    subject(:adjacent?) { time_slot.adjacent?(other) }

    let(:time_slot) { described_class.new(starting_time: starting_time, ending_time: ending_time) }
    let(:other) { described_class.new(starting_time: other_starting_time, ending_time: other_ending_time) }
    let(:starting_time) { 100 }
    let(:ending_time) { 200 }

    context "when starting_time adjacent to other time slot ending_time" do
      let(:other_starting_time) { starting_time - 10 }
      let(:other_ending_time) { starting_time - 1 }

      it { is_expected.to eq true }
    end

    context "when ending_time adjacent to other time slot starting time" do
      let(:other_starting_time) { ending_time + 1 }
      let(:other_ending_time) { ending_time + 10 }

      it { is_expected.to eq true }
    end

    context "when not adjacent" do
      let(:other_starting_time) { ending_time + 10 }
      let(:other_ending_time) { ending_time + 20 }

      it { is_expected.to eq false }
    end
  end

  # This also tests #overlaps?
  describe "#does_not_overlap?" do
    subject(:dependent?) { time_slot.does_not_overlap?(other) }

    let(:time_slot) { described_class.new(starting_time: starting_time, ending_time: ending_time) }
    let(:other) { described_class.new(starting_time: other_starting_time, ending_time: other_ending_time) }

    context "when starting_time >= other.starting_time <= ending_time" do
      let(:starting_time) { 100 }
      let(:ending_time) { 200 }
      let(:other_starting_time) { 199 }
      let(:other_ending_time) { 202 }

      it { is_expected.to be false }
    end

    context "when starting_time >= other.ending_time <= ending_time" do
      let(:starting_time) { 100 }
      let(:ending_time) { 200 }
      let(:other_starting_time) { 98 }
      let(:other_ending_time) { 100 }

      it { is_expected.to be false }
    end

    context "when other.starting_time <= starting time && other.ending_time >= ending_time" do
      let(:starting_time) { 100 }
      let(:ending_time) { 200 }
      let(:other_starting_time) { 99 }
      let(:other_ending_time) { 201 }

      it { is_expected.to be false }
    end

    context "when not overlapping" do
      let(:starting_time) { 100 }
      let(:ending_time) { 200 }
      let(:other_starting_time) { 201 }
      let(:other_ending_time) { 202 }

      it { is_expected.to be true }
    end
  end
end
