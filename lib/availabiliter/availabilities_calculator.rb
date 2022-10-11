require_relative "output_formatter"
require_relative "input_formatter"
require_relative "time_slot_collection"

class Availabiliter
  # Centralize and orchestrate all behavior for availabilities calculations
  class AvailabilitiesCalculator
    attr_reader :raw_time_slots, :minimum_availability_start, :maximum_availability_end, :format, :time_zone

    def initialize(raw_time_slots, minimum_availability_start:, maximum_availability_end:, format:, time_zone:)
      @raw_time_slots = raw_time_slots
      @minimum_availability_start = minimum_availability_start
      @maximum_availability_end = maximum_availability_end
      @format = format
      @time_zone = time_zone
    end

    def call
      output_availabilities
    end

    private

    def time_slots
      InputFormatter.new(input_array: raw_time_slots, time_zone: time_zone).time_slots
    end

    def availabilities
      time_slot_collection.availabilities
    end

    def output_availabilities
      OutputFormatter.new(availabilities, format: format, time_zone: time_zone).format_availabilities
    end

    def time_slot_collection
      TimeSlotCollection.new(time_slots: time_slots, minimum_availability_start: minimum_availability_start,
                             maximum_availability_end: maximum_availability_end)
    end
  end
end
