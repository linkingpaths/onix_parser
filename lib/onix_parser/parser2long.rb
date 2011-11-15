module OnixParser
  class Parser2long

    def self.find_products(doc, &block)
      doc.root.search('/Product').each do |product|
        parsed_values = {}
        parsed_values[:title] = product.search('/Title/TitleText').first.innerText
        contributor_nodes = product.search('/Contributor/PersonName')
        if contributor_nodes.any?
          parsed_values[:author] = contributor_nodes.collect(&:innerText).joi(',')
        else
          contributor_nodes = product.search('/Contributor/PersonNameInverted')
          if contributor_nodes.any?
            parsed_values[:author] = contributor_nodes.collect{|node|
              name_parts = node.innerText.split(', ')
              "#{name_parts.last.strip} #{name_parts.first.strip}"
            }.join(',')
          end
        end

        parsed_values[:publisher] = product.search('/Publisher/PublisherName').text

        synopsis_nodes = product.search("/OtherText/TextTypeCode[text() = '02']/../Text")
        parsed_values[:synopsis] = synopsis_nodes.first.innerText.gsub(/<\/?[^>]*>/, "") if synopsis_nodes.any?

#        subject = product.search('').text
        parsed_values[:subject] = nil

        isbn10_node = product.search("/ProductIdentifier/ProductIDType[text() = '02']/../IDValue")
        gtin_node = product.search("/ProductIdentifier/ProductIDType[text() = '03']/../IDValue")
        isbn_node = product.search("/ProductIdentifier/ProductIDType[text() = '15']/../IDValue")
        parsed_values[:isbn10] = isbn10_node.any? ? isbn10_node.first.innerText : ''
        parsed_values[:gtin] = gtin_node.any? ? gtin_node.first.innerText : ''
        parsed_values[:isbn] = isbn_node.any? ? isbn_node.first.innerText : ''
        parsed_values[:upc] = ''

        # TODO: other file types
        file_path = "/tmp/#{parsed_values[:isbn]}.jpg"
        parsed_values[:cover] = File.exists?(file_path) ? File.new(file_path) : nil

        parsed_values[:excerpt] = nil
        parsed_values[:xml] = product.to_s

        yield OnixParser::Product.new(parsed_values)
      end
    end

  end
end