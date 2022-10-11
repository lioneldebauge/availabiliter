class Availabiliter
  # A TimeSlot represent a slot in time with a start and an end that can be finite or infinite.
  # It can also act as a boundary in availabilities calculation.
  class TimeSlot
    attr_reader :starting_time, :ending_time, :boundary

    def initialize(starting_time:, ending_time:, boundary: false)
      @starting_time = starting_time
      @ending_time = ending_time
      @boundary = boundary
      validate
    end

    def furthest(other)
      [self, other].max_by(&:ending_time)
    end

    def dependent?(other)
      adjacent?(other) || overlaps?(other)
    end

    def next_second
      ending_time + 1
    end

    def previous_second
      starting_time - 1
    end

    def overlaps?(other)
      !does_not_overlap?(other)
    end

    def does_not_overlap?(other)
      starting_time > other.ending_time || ending_time < other.starting_time
    end

    def adjacent?(other)
      other.ending_time == previous_second || other.starting_time == next_second
    end

    private

    def validate
      return if ending_time >= starting_time

      raise IncorrectInput, "A time slot ending time must be equal or greater than its starting time"
    end
  end
end
