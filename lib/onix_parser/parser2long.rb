module OnixParser
  class Parser2long
    def self.find_products(doc)
      products = []

      doc.search('//product').each do |product|
        parsed_values = {}
        parsed_values[:title] = product.search('//title/TitleText').first.innerText
        parsed_values[:author] = product.search('//contributor/PersonName').collect(&:innerText).join(',')
        parsed_values[:publisher] = product.search('//publisher/PublisherName').text
        parsed_values[:synopsis] = product.search('//othertext/Text').first.innerText.gsub(/<\/?[^>]*>/, "")

#        subject = product.search('').text
        parsed_values[:subject] = nil

        isbn_node = product.search('//productidentifier/ISBN')
        isbn_node = product.search('//productidentifier/IDValue') unless isbn_node.present?
        parsed_values[:isbn] = isbn_node.first.innerText

        # TODO: other file types
        file_path = "/tmp/#{parsed_values[:isbn]}.jpg"
        parsed_values[:cover] = File.exists?(file_path) ? File.new(file_path) : nil

        parsed_values[:excerpt] = nil
        parsed_values[:xml] = product.to_s

        products << OnixParser::Product.new(parsed_values)
      end

      products
    end
  end
end