module OnixParser
  class Parser2long
    def self.find_products(doc)
      products = []

      doc.search('//product').each do |product|
        title = product.search('//title/TitleText').text
        author = product.search('//contributor/PersonName').text
        publisher = product.search('//publisher/PublisherName').text
        synopsis = product.search('//othertext/Text').first.innerText.gsub(/<\/?[^>]*>/, "")

#        subject = product.search('').text
        subject = nil

        isbn_node = product.search('//productidentifier/ISBN')
        isbn_node = product.search('//productidentifier/IDValue') unless isbn_node.present?
        isbn = isbn_node.first.innerText

        # TODO: other file types
        file_path = "/tmp/#{isbn}.jpg"
        cover = File.exists?(file_path) ? File.new(file_path) : nil

        products << OnixParser::Product.new(title, author, subject, publisher, cover, synopsis, isbn)
      end

      products
    end
  end
end