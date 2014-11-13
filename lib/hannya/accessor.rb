require 'hannya/address_converter'

module Hannya

  class DataAccessor

    def initialize(source, converter=nil)
      @source = source
      @converter = converter || default_converter
    end

    def [](*keys)
      return values_with_predicates(keys, &block) if block_given?
      return value(keys.first) if keys.count == 1
      values_at(keys)
    end

    protected

    def values_with_predicate(keys, &block)
      values_at(Array(keys)).select(&block)
    end

    private

    def default_converter
      DataAddressConverter.create(:upper)
    end


    def value(key)
      @source[@converter.convert(key)]
    end

    def values_at(keys)
      keys.map do |key|
        @source[@converter.convert(key)]
      end.reject(&:nil?)
    end

  end

  class DataFinder

    def initialize(source, converter=nil)
      @source = source
      @converter = converter || default_converter
    end

    def get(addr='', opts={}, &block)
      results = find_address(addr, opts)
      results = Array(results).select(&block) if block_given?
      results
    end

    private

    def default_converter
      DataAddressConverter.create(:upper)
    end

    def find_address(addr, opts)
      found = find_values(addr)
      return found if opts[:force_array] or found.size > 1
      return found if found.empty? && Array(addr).size > 1
      found.first
    end

    def find_values(addr)
      Array(addr).each_with_object([]) do |a, found|
        value = @source[@converter.convert(a)]
        found << value unless value.is_a?(String)
      end
    end

  end

  class XMLDataFinder < DataFinder

    private

    def default_converter
      DataAddressConverter.create(:camel)
    end

    def find_address(addr, opts)
      accessors = get_multiple_values(addr)
      return accessors if opts[:force_array] || accessors.size > 1
      return accessors if accessors.empty? && Array(addr).size > 1
      accessors.first
    end

    def query_xml(addr)
      @source.xpath(@converter.convert(addr)).map do |node|
        XMLDataAccessor.new(node, @converter)
      end
    end

    def get_multiple_values(addr)
      Array(addr).map do |a|
        query_xml(a)
      end.flatten
    end

  end


  class XMLDataAccessor < DataAccessor

    private

    def default_converter
      DataAddressConverter.create(:camel)
    end

    def value(key)
      get_values(key)
    end

    def values_at(keys)
      get_multiple_values(keys)
    end

    def get_values(keyname)
      values = nodeset2value_list(keyname)
      return if values.empty?
      values.length == 1 ? values.first : values
    end

    def get_multiple_values(keys)
      Array(keys).map do |key|
        get_values(key)
      end.flatten
    end

    def nodeset2value_list(keyname)
      nodes = query_xml(keyname)
      nodes.map(&:text)
    end

    def query_xml(keyname)
      xpath = @converter.convert(keyname)
      @source.xpath(xpath)
    end

  end

end
