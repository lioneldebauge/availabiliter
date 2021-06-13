# frozen_string_literal: true

require_relative "availabiliter/version"
require_relative "availabiliter/timeframe"

# Availability calculator class
module Availabiliter
  class << self
    def get_availabilities(array, timeframe_start = nil)
      TimeFrame.new(array, timeframe_start).availabilities
    end
  end
end
