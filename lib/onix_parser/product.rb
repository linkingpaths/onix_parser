module OnixParser
  class Product
    attr_accessor :title, :author, :subject, :publisher, :cover, :synopsis,
                  :isbn, :isbn10, :upc, :gtin, :lang, :country, :xml, :prices,
                  :excerpt, :other_isbn, :cover_url, :other_ids, :publishing_status,
                  :released_at, :sales_rights, :available, :format
    alias_method :available?, :available
    #alias_method :available?=, :available=   available? is readonly

    def initialize(parsed_values)
      self.title      = parsed_values[:title]
      self.author     = parsed_values[:author]
      self.subject    = parsed_values[:subject]
      self.publisher  = parsed_values[:publisher]
      self.cover      = parsed_values[:cover]
      self.synopsis   = parsed_values[:synopsis]
      self.isbn       = parsed_values[:isbn]
      self.other_isbn = parsed_values[:other_isbn]
      self.isbn10     = parsed_values[:isbn10]
      self.gtin       = parsed_values[:gtin]
      self.upc        = parsed_values[:upc]
      self.lang       = parsed_values[:language]
      self.country    = parsed_values[:country]
      self.xml        = parsed_values[:xml]
      self.prices     = process_prices(parsed_values[:prices])
      self.excerpt    = parsed_values[:excerpt]
      self.cover_url  = parsed_values[:cover_url]
      self.other_ids  = parsed_values[:other_ids]
      self.available  = parsed_values[:available]
      self.released_at = parsed_values[:released_at]
      self.publishing_status     = parsed_values[:publishing_status]
      self.sales_rights          = parsed_values[:sales_rights]
      self.format     = parsed_values[:format]
    end

    protected

    def process_prices(prices)
      prices.map do |price|
        price[:percent_due_publisher] = find_percent_due_publisher(price[:percent_due_publisher])
        price
      end
    end

    def find_percent_due_publisher(value)
      unless value.nil?
        case value.downcase
        when 't', 'x'
          50
        when 'n', 'r', 'k', 'y'
          25
        end
      end
    end
  end
end
