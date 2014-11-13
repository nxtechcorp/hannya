require 'hannya/accessor'
require 'hannya/address_converter'

# A data access layer module.  A hannya in Japan is a female demon
# represented in Japanese theater using a distinctive mask.  Hannya
# the library puts a (demonic? okay, maybe not) mask over a data source,
# allowing you to access it in a simple way.
module Hannya

  def self.Accessor(source, opts)
    converter = opts[:address_converter]
    args = converter ? [source, DataAddressConverter.create(converter)] : [source]
    case source.class.to_s
    when /^Nokogiri::XML/ then XMLDataAccessor.new(*args)
    when /Hash/, /Array/ then DataAccessor.new(*args)
    else raise "Unknown source type #{source.class}"
    end
  end

  def self.Finder(source, opts)
    converter = opts[:address_converter]
    args = converter ? [source, DataAddressConverter.create(converter)] : [source]
    case source.class.to_s
    when /^Nokogiri::XML/ then XMLDataFinder.new(*args)
    when /Hash/, /Array/ then DataFinder.new(*args)
    else raise "Unknown source type #{source.class}"
    end
  end

end
