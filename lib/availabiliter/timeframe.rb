# frozen_string_literal: true

require_relative "date_range"

module Availabiliter
  # A TimeFrame is an object representing several DateRange instances. It can have a start.
  # It can have only one endless DateRange.
  class TimeFrame
    attr_reader :start_date, :date_ranges

    def initialize(array, start_date = nil)
      @start_date = start_date
      @date_ranges = build_date_ranges(array)

      raise ArgumentError unless valid?
    end

    def availabilities
      return [start_date..nil] if date_ranges.empty?
      return build_availabilities if start_date.nil?

      availabilities = build_availabilities
      start_date < first_date_range.start_date ? availabilities.unshift(first_availability) : availabilities
    end

    private

    def build_date_ranges(array)
      date_range_array = array.filter_map do |range|
        next if out_of_timeframe?(range.end)

        DateRange.new(range.begin, range.end)
      end

      date_range_array.sort_by(&:start_date)
    end

    def build_availabilities
      furthest_date_range = first_date_range

      date_ranges.filter_map.with_index do |date_range, index|
        next_date_range = date_ranges[index + 1]

        furthest_date_range = furthest_date_range.furthest(date_range)
        furthest_date_range.next_availability(next_date_range)
      end
    end

    def out_of_timeframe?(range_end)
      !start_date.nil? && (!range_end.nil? && range_end < start_date)
    end

    def first_availability
      start_date..first_date_range.yesterday
    end

    def first_date_range
      date_ranges.first
    end

    def valid?
      end_date_valid? && date_ranges.count { |date_range| date_range.end_date.nil? } <= 1
    end

    def end_date_valid?
      start_date.instance_of?(Date) || start_date.instance_of?(NilClass)
    end
  end
end
