require "benchmark"
require "date"
require_relative "../lib/availabiliter"

desc "Benchmark easily the performance of gem"
task :measure_performance do
  Benchmark.bm do |benchmark|
    raw_time_slots = build_raw_time_slots(1000)
    benchmark.report(:one_thousand_raw_time_slots) { Availabiliter.call(raw_time_slots) }

    raw_time_slots = build_raw_time_slots(10_000)
    benchmark.report(:ten_thousand_raw_time_slots) { Availabiliter.call(raw_time_slots) }

    raw_time_slots = build_raw_time_slots(100_000)
    benchmark.report(:one_hundrer_thousand_raw_time_slots) { Availabiliter.call(raw_time_slots) }
  end
end

def build_raw_time_slots(number)
  date_range = Date.new(2020, 1, 1)..Date.new(2030, 1, 1)
  timestamp_range = 1_577_833_200..1_893_452_400
  time_range = Time.new(2020, 1, 1)..Time.new(2030, 1, 1)
  rand_array = [date_range, timestamp_range, time_range]

  number.times.each_with_object([]) do |_i, array|
    starting_time = Random.rand(rand_array.sample)
    finish_time = starting_time + Random.rand(1000)

    array << [starting_time, finish_time]
  end
end
