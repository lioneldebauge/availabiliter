# frozen_string_literal: true

require "date"

module Availabiliter
  # DateRange is a Range with only dates
  # DateRange start_date is always the earliest date and end_date the latest date
  class DateRange < Range
    include Comparable

    alias start_date begin
    alias end_date end

    def initialize(start_date, end_date)
      super
      raise ArgumentError, "bad value for DateRange" unless valid?
    end

    def independent?(other)
      return true if other.nil?

      !overlaps?(other) && !adjacent?(other)
    end

    def tomorrow
      end_date&.next_day
    end

    def yesterday
      start_date.prev_day
    end

    ## adjacent == touches but doesn't overlap other DateRange
    def adjacent?(other)
      return other.end_date == yesterday if end_date.nil?

      other.end_date == yesterday || other.start_date == tomorrow
    end

    def overlaps?(other)
      cover?(other.begin) || other.cover?(first)
    end

    def next_availability(next_date_range)
      return if end_date.nil?
      return tomorrow..nil if next_date_range.nil?
      return unless independent?(next_date_range)

      gap_start = tomorrow
      gap_end = next_date_range.yesterday

      gap_start..gap_end
    end

    def furthest(other)
      return self if end_date.nil? || other.nil?
      return other if other.end_date.nil?

      [self, other].max_by(&:end_date)
    end

    private

    def valid?
      start_date.instance_of?(Date) && (end_date.nil? || start_date < end_date)
    end
  end
end
