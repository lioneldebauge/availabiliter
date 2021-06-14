# Availabiliter

Availabiliter is a Ruby availability calculator for date ranges. It handles the following edge cases:

- endless date ranges
- overlapping date ranges
- consecutive date ranges
- one day date ranges

It also allows to calculate availabilities from a dedicated date in time.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'availabiliter'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install availabiliter

## Usage

```ruby
# Build an array with all the date ranges you are looking an availability for
holidays = [Date.new(1999, 1, 2)..Date.new(1999, 5, 1), Date.new(2000, 1, 1)..Date.new(2000, 2, 1), Date.new(2000, 3, 1)..nil]

Availabiliter.get_availabilities(holidays)
# => [Date.new(1999, 5, 2)..Date.new(1999, 12, 31), Date.new(2000, 2, 2)..Date.new(2000, 2, 29)]

# If you want to retrieve availabilities starting from a specific date simply add it as a second argument
Availabiliter.get_availabilities(holidays, Date.new(1999, 12, 15))
# => [Date.new(1999, 12, 15)..Date.new(1999, 12, 31), Date.new(2000, 2, 2)..Date.new(2000, 2, 29)]

# If all of your date ranges have an end the last availability will be endless
holidays = [Date.new(1999, 1, 2)..Date.new(1999, 5, 1)]

Availabiliter.get_availabilities(holidays)
# => [Date.new(1999, 5, 2)..]

```
## Dependencies

This gem depends solely on Active Support gem. One of the future planned improvement is to remove this dependency.

## Future improvements

- remove any dependency from the project
- support Datetime
- support beginless ranges

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/lioneldebauge/availabiliter.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
