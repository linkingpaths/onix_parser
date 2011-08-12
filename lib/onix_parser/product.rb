module OnixParser
  class Product
    attr_accessor :title, :author, :subject, :publisher, :cover, :synopsis,
                  :isbn, :isbn10, :upc, :gtin, :lang, :country, :xml, :prices,
                  :excerpt, :other_isbn

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
      self.prices     = parsed_values[:prices]
      self.excerpt    = parsed_values[:excerpt]
    end


  end
end
