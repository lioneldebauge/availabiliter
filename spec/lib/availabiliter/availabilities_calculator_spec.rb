RSpec.describe Availabiliter::AvailabilitiesCalculator do
  describe "#initialize" do
    subject(:new) { described_class.new(raw_time_slots, **parameters) }

    let(:parameters) { { minimum_availability_start: minimum_availability_start, maximum_availability_end: maximum_availability_end, format: format, time_zone: time_zone } }
    let(:raw_time_slots) do
      [[120_202, 292_929], [Date.new(2021, 1, 1), Date.new(2022, 1, 1)], Time.new(1999, 1, 1), Time.new(2000, 1, 1)]
    end
    let(:minimum_availability_start) { Date.new(2021, 1, 1) }
    let(:maximum_availability_end) { Date.new(2022, 1, 1) }
    let(:format) { :integer }
    let(:time_zone) { "+02:00" }

    it { is_expected.to be_an_instance_of(described_class) }
    it { is_expected.to have_attributes(raw_time_slots: raw_time_slots, **parameters) }
  end

  describe "#call" do
    subject(:call) { availabilities_calculator.call }

    let(:availabilities_calculator) { described_class.new(raw_time_slots, **default_options) }
    let(:default_options) { { minimum_availability_start: -Float::INFINITY, maximum_availability_end: Float::INFINITY, format: :integer, time_zone: "+02:00" } }
    let(:expected_availabilities) { [[-Float::INFINITY, 12_929_291], [92_292_930, 1_609_451_999], [1_656_723_601, Float::INFINITY]] }
    let(:raw_time_slots) do
      [
        [Date.new(2021, 1, 1), Date.new(2022, 3, 1)],
        [12_929_292, 92_292_929],
        [Time.new(2022, 1, 2, 3, 0, 0, "+02:00"), Time.new(2022, 7, 2, 3, 0, 0, "+02:00")]
      ]
    end

    it "returns availabilities to the right format" do
      expect(call).to eq expected_availabilities
    end

    context "when there is no availabilities possible" do
      let(:raw_time_slots) { [[-Float::INFINITY, Float::INFINITY]] }

      it { is_expected.to be_empty }
    end

    context "when there is no raw time slots" do
      let(:raw_time_slots) { [] }

      it "returns one availability with the minimum availability start and the maximum availability end" do
        expect(call).to eq [[default_options[:minimum_availability_start], default_options[:maximum_availability_end]]]
      end
    end
  end
end
