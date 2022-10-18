require_relative "time_slot"
require "forwardable"

class Availabiliter
  # A time slot collection is a sorted collection of time slots with a start and an end boundary
  class TimeSlotCollection
    include Enumerable
    attr_reader :collection

    def initialize(time_slots:, minimum_availability_start:, maximum_availability_end:)
      @minimum_availability_start = minimum_availability_start
      @maximum_availability_end = maximum_availability_end
      @collection = build_collection(time_slots)
    end

    def availabilities
      furthest_time_slot = start_boundary

      filter_map.with_index do |time_slot, index|
        next_time_slot = collection[index + 1]
        furthest_time_slot = time_slot.furthest(furthest_time_slot)

        next if index == last_time_slot_index
        next if furthest_time_slot.dependent?(next_time_slot)

        [furthest_time_slot.next_second, next_time_slot.previous_second]
      end
    end

    private

    attr_reader :minimum_availability_start, :maximum_availability_end

    def build_collection(time_slots)
      time_slots.then do |array|
        array.sort_by!(&:starting_time)
        array.unshift(start_boundary)
        array.push(end_boundary)
      end
    end

    def each(&block)
      collection.each(&block)
    end

    def start_boundary
      TimeSlot.new(starting_time: -Float::INFINITY, ending_time: minimum_availability_start - 1, boundary: true)
    end

    def end_boundary
      TimeSlot.new(starting_time: maximum_availability_end + 1, ending_time: Float::INFINITY, boundary: true)
    end

    def last_time_slot_index
      @last_time_slot_index ||= count - 1
    end
  end
end
