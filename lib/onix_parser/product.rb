module OnixParser
  class Product
    attr_accessor :title, :author, :subject, :publisher, :cover, :synopsis, :isbn, :xml

    def initialize(title, author, subject, publisher, cover, synopsis, isbn, xml)
      self.title = title
      self.author = author
      self.subject = subject
      self.publisher = publisher
      self.cover = cover
      self.synopsis = synopsis
      self.isbn = isbn
      self.xml = xml
    end
  end
end
