module OnixParser
  class Parser2short
    def self.find_products(doc)
      products = []

      doc.root.search('/product').each do |product|
        title = product.search('/title/b203').first.innerText.strip
        author = product.search('/contributor/b036').collect(&:innerText).join(',')
        publisher = product.search('/publisher/b081').text.strip
        synopsis = product.search('/othertext/d104').first.innerText.gsub(/<\/?[^>]*>/, "").strip
        language = product.search('/language/b252').first.innerText.strip
        country = ''

#        subject = product.search('').text
        subject = nil

        isbn_node = product.search('//productidentifier/b004')
        isbn_node = product.search('//productidentifier/b244') unless isbn_node.any?
        isbn = isbn_node.first.innerText

        isbn10 = ''
        gtin = ''
        upc = ''

        file_path = "/tmp/#{isbn}.jpg"
        cover = File.exists?(file_path) ? File.new(file_path) : nil

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

        excerpt_node = product.search("/othertext/d102[text() = '23']/../d104")
        excerpt = ''
        if(excerpt_node.any?)
          excerpt = excerpt_node.first.innerText

        end
        

        products << OnixParser::Product.new(title, author, subject, publisher, cover, synopsis, isbn, isbn10, gtin, upc, language, country, prices, product.to_s, excerpt)
      end

      products
    end
  end
end