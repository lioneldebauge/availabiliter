require_relative "time_slot"

class Availabiliter
  # Convert raw time slots to TimeSlot instances
  class InputFormatter
    attr_reader :input_array, :time_zone

    def initialize(input_array:, time_zone:)
      @input_array = input_array
      @time_zone = time_zone
    end

    def time_slots
      input_array.map do |time_slot_input|
        validate_time_slot_input(time_slot_input)

        TimeSlot.new(starting_time: to_timestamp(time_slot_input.first),
                     ending_time: to_timestamp(time_slot_input.last))
      end
    end

    private

    def validate_time_slot_input(time_slot_input)
      return if  time_slot_input.size == 2

      raise IncorrectInput, "In the array input there is a time slot array which size is different from 2"
    end

    def to_timestamp(value)
      case value.class.to_s
      when "Time" then value.to_i
      when "Date"
        convert_date(value)
      else
        value
      end
    end

    def convert_date(date)
      if time_zone
        Time.new(date.year, date.month, date.day, 0, 0, 0, time_zone).to_i
      else
        date.to_time.to_i
      end
    end
  end
end
