require 'hannya/address_converter'

# A data access layer module.  A hannya in Japan is a female demon
# represented in Japanese theater using a distinctive mask.  Hannya
# the library puts a (demonic? okay, maybe not) mask over a data source,
# allowing you to access it in a simple way.
module Hannya

  # Put the hannya mask over your data.
  # @param source [Nokogiri::XML::Node, Hash, Array] the data source
  # @param opts [Hash] the options
  # @option opts [Boolean] :force_array whether to always return an array
  # @option opts [Hannya::DataAddressConverter] :converter the address converter object.
  #   This is what converts symbols into strings that will return a result from the data
  #   source.
  def self.Mask(source, opts={})
    case source
    when Nokogiri::XML::Node then XMLAccessor.new(source, opts)
    when Hash then HashAccessor.new(source, opts)
    else raise TypeError, "Unknown source type: #{source.class}"
    end
  end

  class Mask
    # @!attribute [r] source [Nokogiri::XML::Node, Hash, Array] the data source
    attr_reader :source

    def initialize(source, opts={})
      @opts_hash = opts
      @source = source
      @converter = opts.fetch(:converter) { default_converter }
      @force_array = opts[:force_array]
    end

    def create_method(method_name, query_result)
      define_singleton_method(method_name) do
        create_result_list(query_result)
      end
    end

    def [](key)
      query_result = execute_query(key)
      create_result_list(query_result)
    end

    # TODO: This is ugly
    def create_result_list(query_result)
      return create_result_list_from_hash(query_result) if query_result.is_a?(Hash)
      create_result_list_from_array(query_result)
    end

    def create_result_list_from_array(query_result)
      result_list = Array(query_result).map do |node|
        get_text_or_node(node)
      end
      scalarize(result_list)
    end

    def create_result_list_from_hash(query_result)
      query_result.each_with_object({}) do |(key, value), result_list|
        result_list[key] = get_text_or_node(value)
      end
    end

    def list(*keys)
      keys.map do |key|
        send key
      end
    end

    def respond_to_missing(method_name, include_private)
      !execute_query(@converter.convert method_name).empty?
    end

    def method_missing(method_name, *args, &block)
      result = execute_query(@converter.convert method_name)
      return scalarize(Array(nil)) if result.empty?
      create_method(method_name, result)
      send(method_name)
    end

    def scalarize(array)
      return array if array.count > 1 || @force_array
      array.first
    end

    def wrap_data(node)
      self.class.new(node, @opts_hash)
    end
  end

  class XMLAccessor < Mask
    def execute_query(xpath)
      @source.xpath(xpath)
    end

    def get_text_or_node(node)
      if node.element_children.empty?
        node.text
      else
        wrap_data(node)
      end
    end

    def default_converter
      DataAddressConverter.create(:camel)
    end
  end

  class HashAccessor < Mask
    def execute_query(key)
      return Array(@source[key]) unless @source[key].is_a?(Hash)
      @source[key]
    end

    def get_text_or_node(node)
      case node
      when String, Array then node
      when Hash then wrap_data(node)
      end
    end

    def default_converter
      DataAddressConverter.create(:upper)
    end
  end

end
