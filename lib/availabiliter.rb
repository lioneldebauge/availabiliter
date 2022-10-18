require_relative "availabiliter/version"
require_relative "availabiliter/availabilities_calculator"
require_relative "availabiliter/errors"
require_relative "availabiliter/options_validator"
require "date"

# Availabilityer main class and namespace
class Availabiliter
  PROCESSABLE_FORMATS = %i[time integer].freeze
  DEFAULT_FORMAT = :integer
  PROCESSABLE_TIME_CLASSES = [Date, Time, Integer, Float].freeze

  class << self
    def call(raw_time_slots, **options)
      new(raw_time_slots, options).calculate
    end
  end

  def initialize(raw_time_slots, options)
    @options = default_options.merge(options)
    @raw_time_slots = raw_time_slots

    validate_options
  end

  def calculate
    AvailabilitiesCalculator.new(raw_time_slots, **options).call
  end

  private

  attr_reader :raw_time_slots, :options

  def default_options
    {
      minimum_availability_start: -Float::INFINITY,
      maximum_availability_end: Float::INFINITY,
      format: DEFAULT_FORMAT,
      time_zone: nil
    }
  end

  def validate_options
    OptionsValidator.new(options).call
  end
end
