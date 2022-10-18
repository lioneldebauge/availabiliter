# Availabiliter

Calulating gaps/availabilities between two time slots should be easy right ? Well very often it is not because of various edge cases like:
- endless or beginless time slots
- overlapping time slots
- consecutive time slots
- one second time slots
- different time zones

Availabiter is a tested and documented Ruby libary which provides an easy way of performing this calculation while handling all edge cases above.

## Basic example

For this given array of time slots...

```ruby
require "availabiliter"

shift_1 = [Time.new(2021, 1, 1, 8), Time.new(2021, 1, 1, 12)]
shift_2 = [Time.new(2021, 1, 1, 14), Time.new(2021, 1, 1, 18)]
working_hours = [shift_1, shift_2]
```

...you can calculate the gaps between those time slots by doing the following.

```ruby
Availabiliter.call(working_hours, format: :time)
# returns:
# [
# 	[-Infinity, 2021-01-01 07:59:59 +0100],
# 	[2021-01-01 12:00:01 +0100, 2021-01-01 13:59:59 +0100],
# 	[2021-01-01 18:00:01 +0100, Infinity]
# ]
```


## Features

### Overlapping time slots

```ruby
shift_1 = [Time.new(2021, 1, 1, 12), Time.new(2021, 1, 1, 20)]
shift_2 = [Time.new(2021, 1, 1, 10), Time.new(2021, 1, 1, 22)]
available_hours = [shift_1, shift_2]

Availabiliter.call(working_hours, format: :time)
# => [[-Infinity, 2021-01-01 09:59:59 +0100], [2021-01-01 22:00:01 +0100, Infinity]]
```

## Consecutive time slots

```ruby
shift_1 = [Time.new(2021, 1, 1, 12), Time.new(2021, 1, 1, 20, 0, 1)]
shift_2 = [Time.new(2021, 1, 1, 20, 0, 1), Time.new(2021, 1, 1, 22)]
working_hours = [shift_1, shift_2]

Availabiliter.call(working_hours, format: :time)
# => [[-Infinity, 2021-01-01 11:59:59 +0100], [2021-01-01 22:00:01 +0100, Infinity]]
```

### Endless or beginless time slots

```ruby
shift_1 = [-Float::INFINITY, Time.new(2021, 1, 1, 12)]
shift_2 = [Time.new(2021, 1, 2, 8), Float::INFINITY]
working_hours = [shift_1, shift_2]

Availabiliter.call(working_hours, format: :time)
# => [[2021-01-01 12:00:01 +0100, 2021-01-02 07:59:59 +0100]]
```

### Boundaries

```ruby
minimum_availability_start = Time.new(2021, 1, 1, 6)
maximum_availability_end = Time.new(2021, 1, 1, 11)

shift_1 = [Time.new(2021, 1, 1, 8), Time.new(2021, 1, 1, 12)]
working_hours = [shift_1]

Availabiliter.call(
	working_hours,
	minimum_availability_start: minimum_availability_start,
	maximum_availability_end: maximum_availability_end,
	format: :time
)
# => [[2021-01-01 06:00:00 +0100, 2021-01-01 07:59:59 +0100]]
```

### Format

```ruby
shift = [Time.new(2021, 1, 1, 8), Time.new(2021, 1, 1, 12)]
working_hours = [shift]

Availabiliter.call(working_hours)
# => [[-Infinity, 1609484399], [1609498801, Infinity]]

Availabiliter.call(working_hours, format: :time)
# => [[-Infinity, 2021-01-01 07:59:59 +0100], [2021-01-01 12:00:01 +0100, Infinity]]
```

### Timezone

```ruby
time_zone = "+00:00"
shift = [Time.new(2021, 1, 1, 8, 0, 0, time_zone), Time.new(2021, 1, 1, 12, 0, 0, time_zone)]
working_hours = [shift]

Availabiliter.call(working_hours, time_zone: "+10:00", format: :time)
# => [[-Infinity, 2021-01-01 17:59:59 +1000], [2021-01-01 22:00:01 +1000, Infinity]]
```

When a time zone is not specifed by default Ruby determines the time zone according to the current system time.

## Usage

### Expected input

Expected input is an array of arrays. Each of those subarray should represent a time slot with the first element being the time slot start and the last element being the time slot end.
A "time slot array" size should contain only 2 elements or an error will be returned.

```ruby
incorrect_shift = [Time.new(2021, 1, 1, 8), Time.new(2021, 1, 1, 12), Time.new(2021, 1, 1, 14)]
working_hours = [incorrect_shift]

Availabiliter.call(working_hours)
# => Availabiliter::IncorrectInput (In the array input there is a time slot array which size is different from 2)
```

Time slot start and end should be instances of `Date`, `Time` and `Integer` classes. `Integer` in that case represent unix timestamps. 
During calculations `Date` instances will be converted to timestamp representing the beginning of the day. Be aware that if a time zone is specified Availabiliter will take it into account while doing this conversion.

### Expected output

The expected output is an array of arrays, each representing an availability. Availabilities are unix timestamps by default but this can be overriden using the `format` option.
The supported output formats are:
- unix timestamps
- Time instances

### Infinity

Time slots with an infinite start or an infinite end are supported. As input positive infinity should be represented with `Float::INFINITY`and negative infinity with `Float::INFINTIY`.
The same values can be expected as output.

### Lowest time value accepted

Since we rely on unix timestamps to deal with time zones, seconds are the lowest time value that can be accepted as an input.

### Performance

Benchmark done with ruby 2.7.2p137 on MacBook Pro (13-inch, M1, 2020) with an Apple M1 processor.

|               | Real time per second |
|---------------|----------------------|
| 1000 input    | 0.004353             |
| 10 000 input  | 0.038922             |
| 100 000 input | 0.401442             |

To do a benchmark on your machine git clone the repo and run `rake measure_performance`.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'availabiliter'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install availabiliter

And require it at the top of a file to run your calculations

```ruby
# some_file.rb
require "availabiliter
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/lioneldebauge/availabiliter.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
