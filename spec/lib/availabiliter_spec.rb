RSpec.describe Availabiliter do
  describe ".call" do
    subject(:call) { described_class.call(raw_time_slots, **optional_parameters) }

    let(:calculator_klass) { Availabiliter::AvailabilitiesCalculator }
    let(:calculator) { instance_double(calculator_klass) }
    let(:validator_klass) { Availabiliter::OptionsValidator }
    let(:validator) { instance_double(validator_klass) }
    let(:raw_time_slots) { [] }

    before do
      allow(calculator_klass).to receive_messages(new: calculator)
      allow(calculator).to receive(:call)
      allow(validator_klass).to receive_messages(new: validator)
      allow(validator).to receive(:call)
    end

    context "when there are no optional parameters" do
      let(:optional_parameters) { {} }
      let(:default_parameters) { { minimum_availability_start: -Float::INFINITY, maximum_availability_end: Float::INFINITY, format: default_format, time_zone: nil } }
      let(:default_format) { Availabiliter::DEFAULT_FORMAT }

      it "instanciates an availability calculator with the default paramters" do
        call
        expect(calculator_klass).to have_received(:new).with(raw_time_slots, **default_parameters)
      end

      it "triggers the availability calculation" do
        call
        expect(calculator).to have_received(:call)
      end

      it "instanciates an options validator with the default parameters" do
        call
        expect(validator_klass).to have_received(:new).with(**default_parameters)
      end

      it "validates the optional parameters" do
        call
        expect(validator).to have_received(:call)
      end
    end

    context "when optional parameters are given" do
      let(:optional_parameters) { { minimum_availability_start: Date.new(2000, 1, 1), maximum_availability_end: Date.new(2001, 1, 1), format: :time, time_zone: "+02:00" } }

      it "instanciates an availability calculator with the given paramters" do
        call
        expect(calculator_klass).to have_received(:new).with(raw_time_slots, **optional_parameters)
      end

      it "triggers the availability calculation" do
        call
        expect(calculator).to have_received(:call)
      end

      it "instanciates an options validator with the given parameters" do
        call
        expect(validator_klass).to have_received(:new).with(**optional_parameters)
      end

      it "validates the optional parameters" do
        call
        expect(validator).to have_received(:call)
      end
    end
  end
end
