class Availabiliter
  # Verify that the options input are valid
  class OptionsValidator
    attr_reader :minimum_availability_start, :maximum_availability_end, :format

    def initialize(minimum_availability_start:, maximum_availability_end:, format:, **_options)
      @minimum_availability_start = minimum_availability_start
      @maximum_availability_end = maximum_availability_end
      @format = format
    end

    def call
      validate_format
      validate_boundary_class
      validate_boundary_value
    end

    private

    def validate_format
      return if PROCESSABLE_FORMATS.include?(format)

      raise IncorrectInput, "#{format} is not an available format"
    end

    def validate_boundary_class
      raise_invalid_boundary_class if invalid_boundary_class?
    end

    def invalid_boundary_class?
      [minimum_availability_start, maximum_availability_end].one? do |boundary|
        PROCESSABLE_TIME_CLASSES.none? { |klass| klass == boundary.class }
      end
    end

    def validate_boundary_value
      raise_invalid_boundary_value if invalid_boundary_value?
    end

    def invalid_boundary_value?
      minimum_availability_start > maximum_availability_end
    end

    def raise_invalid_boundary_class
      raise IncorrectInput, invalid_boundary_class_message
    end

    def raise_invalid_boundary_value
      raise IncorrectInput, "minimum_availability_start can't be greater than maximum_availability_end"
    end

    def invalid_boundary_class_message
      "#{minimum_availability_start.class}, #{maximum_availability_end.class} : one of this boundary class is not valid"
    end
  end
end
