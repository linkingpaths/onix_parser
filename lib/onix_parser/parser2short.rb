module OnixParser
  class Parser2short
    def self.find_products(doc)
      products = []

      doc.root.search('/product').each do |product|
        title = product.search('/title/b203').text.strip
        author = product.search('/contributor/b036').text.strip
        publisher = product.search('/publisher/b081').text.strip
        synopsis = product.search('/othertext/d104').first.innerText.gsub(/<\/?[^>]*>/, "").strip

#        subject = product.search('').text
        subject = nil

        isbn_node = product.search('//productidentifier/b004')
        isbn_node = product.search('//productidentifier/b244') unless isbn_node.any?
        isbn = isbn_node.first.innerText

        # TODO: other file types
        file_path = "/tmp/#{isbn}.jpg"
        cover = File.exists?(file_path) ? File.new(file_path) : nil

        products << OnixParser::Product.new(title, author, subject, publisher, cover, synopsis, isbn, product.to_s)
      end

      products
    end
  end
end