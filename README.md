# Triglav::Agent Framework

Framework of Triglav Agent in Ruby.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'triglav-agent'
```

And then execute:

```
$ bundle
```

## Usage

See [yardoc](https://triglav-dataflow.github.io/triglav-agent-framework-ruby/)

## Examples

See [triglav-agent-vertica](https://github.com/triglav-workflow/triglav-agent-vertica) or [triglav-agent-hdfs](https://github.com/triglav-workflow/triglav-agent-hdfs).

Basically what you have to implement are following classes:

* `Connection`: make a connection to your storage
* `Monitor`: monitor your storage and send messages to triglav

## Development

### Run test

```
bundle exec rake test
```

### Release

```
bundle exec rake release
```

### Generate yardoc

```
bundle exec rake yard
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/triglav-workflow/triglav-agent-framework-ruby. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

