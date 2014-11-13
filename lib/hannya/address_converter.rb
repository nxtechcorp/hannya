module Hannya

  # A factory class that returns a command object whose
  # purpose it just to convert lower-case symbols to
  # a string format used in the data.
  # A data address is a string used to access data, like an
  # XPath, field name, or hash key.
  class DataAddressConverter

    TO_UPPER = ->(key) { key.to_s.upcase }
    TO_CAMEL = ->(key) { key.to_s.split('_').map(&:capitalize).join }

    # @param type [Symbol, Proc] either :upper, :camel, or a proc or lambda.
    # @return AddressConverter
    def self.create(type)
      case type
      when :upper then AddressConverter.new(TO_UPPER)
      when :camel then AddressConverter.new(TO_CAMEL)
      else check_for_proc(type)
      end
    end

    def self.check_for_proc(type)
      return AddressConverter.new(type) if type.respond_to?(:call)
      raise TypeError, "Can't use this address converter"
    end

  end

  # Converts a symbol to a string in a specific format
  class AddressConverter

    def initialize(strategy)
      @strategy = strategy
    end

    # If a symbol is passed in, it attemtps to convert it,
    # otherwise it returns the string passed in.
    # @param text [Symbol, String] something representing a data address
    # @return [String] a formatted string
    def convert(text)
      return text if text.is_a?(String)
      @strategy.call(text)
    end

  end

end
