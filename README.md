# Hannya

Hannya is a simple facade/data access layer that can take in either a
hash (from a YAML or JSON file) or an XML object (from Nokogiri) and
make them both look the same.

Mainly this is for XML. Why? Most of the time, if we are querying XML,
we are looking for text values. This returns the value of a text node,
if there is one at the location specified, and if not, returns another
facade covering the nodeset that was found. You can use direct XPaths by
passing them in brackets. The contents of brackets get passed directly
into Nokogiri's #xpath method.

Support for direct data structures is experimental.  

You can create an instance of Hannya::Mask with a text transformation
rule that translates a snake case symbol to whatever is in the actual
XML, and this will get run on the method name to convert it to an XPath.

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
