module OnixParser
  class Product
    attr_accessor :title, :author, :subject, :publisher, :cover, :synopsis, :isbn

    def initialize(title, author, subject, publisher, cover, synopsis, isbn)
      self.title = title
      self.author = author
      self.subject = subject
      self.publisher = publisher
      self.cover = cover
      self.synopsis = synopsis
      self.isbn = isbn
    end
  end
end
