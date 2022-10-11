RSpec.describe Availabiliter::OutputFormatter do
  describe "#initialize" do
    subject(:new) { described_class.new(availabilities, format: format, time_zone: time_zone) }

    let(:availabilities) { [[-1000, 2000]] }
    let(:time_zone) { "+02:00" }
    let(:format) { :time }

    it { is_expected.to have_attributes(class: described_class, availabilities: availabilities, format: format, time_zone: time_zone) }
  end

  describe "#format_availabilities" do
    subject(:format_availabilities) { output_formatter.format_availabilities }

    let(:output_formatter) { described_class.new(availabilities, format: format, time_zone: time_zone) }
    let(:availabilities) { [[availability_start, availability_end]] }
    let(:availability_start) { -1000 }
    let(:availability_end) { 2000 }
    let(:time_zone) { "+02:00" }

    context "when time format is required as output" do
      let(:format) { :time }
      let(:expected_start) { Time.at(availability_start, in: time_zone) }
      let(:expected_end) { Time.at(availability_end, in: time_zone) }

      context "when time zone is nil" do
        let(:expected_start) { Time.at(availability_start) }
        let(:expected_end) { Time.at(availability_end) }
        let(:time_zone) { nil }

        it "converts the availabilities without a given time zone" do
          expect(format_availabilities).to eq [[expected_start, expected_end]]
        end
      end

      context "when time zone is not nil" do
        let(:expected_start) { Time.at(availability_start, in: time_zone) }
        let(:expected_end) { Time.at(availability_end, in: time_zone) }
        let(:time_zone) { "+02:00" }

        it "converts the availabilities with a given time zone" do
          expect(format_availabilities).to eq [[expected_start, expected_end]]
        end
      end
    end

    context "when integer format is required as output" do
      let(:format) { :integer }

      it "does not convert the availabilities" do
        expect(format_availabilities).to eq availabilities
      end
    end

    context "when an availability has an infinite start or end" do
      let(:availabilities) { [[-Float::INFINITY, Float::INFINITY]] }
      let(:format) { :time }

      it "is not converted" do
        expect(format_availabilities.flatten).to all be_infinite
      end
    end
  end
end
