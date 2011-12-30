require 'hpricot'

module OnixParser
  class Reader
    attr_reader :products
    attr_accessor :onix_version

    def initialize(input, version = nil)
      if input.kind_of?(String)
        @doc = version.nil? ? Hpricot(File.read(input)) : Hpricot(input)
      elsif input.kind_of?(IO)
        @doc = Hpricot(input)
      else
        raise ArgumentError, "Unable to read from file or IO stream"
      end
      
      if version == '3.0' || @doc.root.search('/Product/DescriptiveDetail').any?
        @onix_parser = OnixParser::Parser3
        @onix_version = '3.0'
      elsif version == '2.1 long' || @doc.root.search("/Product/RecordReference").any?
        @onix_parser = OnixParser::Parser2long
        @onix_version = '2.1 long'
      elsif version == '2.1 short' || @doc.search("//a001").any?
        @onix_parser = OnixParser::Parser2short
        @onix_version = '2.1 short'
      else
        raise ArgumentError, "Unable to identify ONIX schema version."
      end

#      @products = @onix_parser.find_products(@doc)
    end

    def each(&block)
      @products.each do |product|
        yield product
      end
    end

    def parse(&block)
      @onix_parser.find_products(@doc, &block)
    end

    def parse_product(&block)
      @onix_parser.parse_product(@doc, &block)
    end
  end
end