require 'hpricot'

module OnixParser
  class Reader
    attr_reader :products

    def initialize(input)
      if input.kind_of?(String)
        @doc = Hpricot(File.read(input))
      elsif input.kind_of?(IO)
        @doc = Hpricot(input)
      else
        raise ArgumentError, "Unable to read from file or IO stream"
      end

      @onix_parser = if @doc.root.search('/Product/DescriptiveDetail').any?
        OnixParser::Parser3
      elsif @doc.search("//RecordReference").any?
        OnixParser::Parser2long
      elsif @doc.search("//a001").any?
        OnixParser::Parser2short
      else
        raise ArgumentError, "Unable to identify ONIX schema version."
      end

      @products = @onix_parser.find_products(@doc)
    end

    def each(&block)
      @products.each do |product|
        yield product
      end
    end
  end
end