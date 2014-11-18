# Hannya

Hannya is a simple data access layer that can take in either a hash (from a YAML or JSON file) or an XML object (from Nokogiri) and make them both look the same.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'hannya'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install hannya

## Usage

```ruby
require 'hannya'

xml = Nokogiri::XML(File.open 'myfile.xml')

accessor = Hannya::Mask(xml)

accessor.root.orders[1].amount # => '12.95'
accessor['Root/Orders[1]/Amount'] # => '12.95'
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/hannya/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
