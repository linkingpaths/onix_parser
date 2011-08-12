module OnixParser
  class Parser2short
    def self.find_products(doc)
      products = []

      doc.root.search('/product').each do |product|
        parsed_values = {}
        parsed_values[:title] = product.search('/title/b203').first.innerText.strip
        parsed_values[:author] = product.search('/contributor/b036').collect(&:innerText).join(',')
        parsed_values[:publisher] = product.search('/publisher/b081').text.strip
        parsed_values[:synopsis] = product.search('/othertext/d104').first.innerText.gsub(/<\/?[^>]*>/, "").strip
        parsed_values[:language] = product.search('/language/b252').first.innerText.strip
        parsed_values[:country] = ''

#        subject = product.search('').text
        parsed_values[:subject] = nil

        isbn_node = product.search('//productidentifier/b004')
        isbn_node = product.search('//productidentifier/b244') unless isbn_node.any?
        parsed_values[:isbn] = isbn_node.first.innerText

        other_isbn_node = product.search("/relatedproduct/h208[text() = '13']/../productidentifier/b244")
        parsed_values[:other_isbn] = other_isbn_node.collect(&:innerText) if other_isbn_node.any?

        parsed_values[:isbn10] = ''
        parsed_values[:gtin] = ''
        parsed_values[:upc] = ''

        file_path = "/tmp/#{parsed_values[:isbn]}.jpg"
        parsed_values[:cover] = File.exists?(file_path) ? File.new(file_path) : nil

        # prices
        prices = []
        price_nodes = product.search('/supplydetail/price')
        if price_nodes.any?
          price_nodes.each do |price_node|
            price_data = {:price => price_node.search('/j151').first.innerText, :start_date => nil, :end_date => nil}
            # Placeholder for PriceEffectiveFrom
            if price_node.search("/j161").any?

            end

            # Placeholder for PriceEffectiveUntil
            if price_node.search("/j162").any?

            end

            prices << price_data
          end
        else
          prices << {:price => 0, :start_date => nil, :end_date => nil}  
        end
        parsed_values[:prices] = prices

        excerpt_node = product.search("/othertext/d102[text() = '23']/../d104")
        parsed_values[:excerpt] = ''
        if(excerpt_node.any?)
          parsed_values[:excerpt] = excerpt_node.first.innerText
        end
        parsed_values[:xml] = product.to_s

        products << OnixParser::Product.new(parsed_values)
      end

      products
    end
  end
end