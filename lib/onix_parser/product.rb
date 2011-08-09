module OnixParser
  class Product
    attr_accessor :title, :author, :subject, :publisher, :cover, :synopsis,
                  :isbn, :isbn10, :upc, :gtin, :lang, :country, :xml, :prices

    def initialize(title, author, subject, publisher, cover, synopsis, isbn, isbn10, gtin, upc, language, country, prices, xml)
      self.title = title
      self.author = author
      self.subject = subject
      self.publisher = publisher
      self.cover = cover
      self.synopsis = synopsis
      self.isbn = isbn
      self.isbn10 = isbn10
      self.gtin = gtin
      self.upc = upc
      self.lang = language
      self.country = country
      self.xml = xml
      self.prices = prices
    end
  end
end
