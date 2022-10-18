RSpec.describe Availabiliter::OptionsValidator do
  describe "#initialize" do
    subject(:new) { described_class.new(**options) }

    let(:options) { { minimum_availability_start: minimum_availability_start, maximum_availability_end: maximum_availability_end, format: format } }
    let(:minimum_availability_start) { -Float::INFINITY }
    let(:maximum_availability_end) { Float::INFINITY }
    let(:format) { :integer }

    it { is_expected.to have_attributes(class: described_class, minimum_availability_start: minimum_availability_start, maximum_availability_end: maximum_availability_end, format: format) }
  end

  describe "#call" do
    subject(:call) { validator.call }

    let(:validator) { described_class.new(**options) }
    let(:options) { { minimum_availability_start: minimum_availability_start, maximum_availability_end: maximum_availability_end, format: format } }
    let(:minimum_availability_start) { -Float::INFINITY }
    let(:maximum_availability_end) { Float::INFINITY }
    let(:format) { :integer }
    let(:input_error) { Availabiliter::IncorrectInput }

    context "when an incorrect format is given" do
      let(:format) { :date }

      it "raises an error" do
        expect { call }.to raise_error input_error, "date is not an available format"
      end
    end

    context "when an incorrect minimum_availability_start is given" do
      let(:minimum_availability_start) { "Some argument" }

      it "raises an error" do
        expect { call }.to raise_error input_error, "String, Float : one of this boundary class is not valid"
      end
    end

    context "when an incorrect maximum_availability_end is given" do
      let(:maximum_availability_end) { "Some argument" }

      it "raises an error" do
        expect { call }.to raise_error input_error, "Float, String : one of this boundary class is not valid"
      end
    end

    context "when minimum_availability_start is greater than maximum_availability_end" do
      let(:minimum_availability_start) { Date.new(2000, 1, 1) }
      let(:maximum_availability_end) { Date.new(1999, 12, 31) }

      it "raises an error" do
        expect { call }.to raise_error input_error, "minimum_availability_start can't be greater than maximum_availability_end"
      end
    end
  end
end
