class Availabiliter
  # Transform availabilities to the required format
  class OutputFormatter
    attr_reader :availabilities, :format, :time_zone

    def initialize(availabilities, format:, time_zone:)
      @availabilities = availabilities
      @format = format
      @time_zone = time_zone
    end

    def format_availabilities
      availabilities.map do |availability|
        convert_to_format(availability)
      end
    end

    private

    def convert_to_format(availability)
      [convert_timestamp(availability.first), convert_timestamp(availability.last)]
    end

    def convert_timestamp(timestamp)
      return timestamp if timestamp.infinite?

      case format
      when :time then convert_time(timestamp)
      else
        timestamp
      end
    end

    def convert_time(timestamp)
      if time_zone
        Time.at(timestamp, in: time_zone)
      else
        Time.at(timestamp)
      end
    end
  end
end
