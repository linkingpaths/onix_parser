module OnixParser
  class Parser2short
    def self.find_products(doc, &block)
      doc.root.search('/product').each do |product|
        parsed_values = {}
        parsed_values[:title] = product.search('/title/b203').first.innerText.strip
        parsed_values[:author] = product.search('/contributor/b036').collect(&:innerText).join(',')
        parsed_values[:publisher] = product.search('/publisher/b081').text.strip

        synopsis_nodes = product.search('/othertext/d104')
        parsed_values[:synopsis] = synopsis_nodes.first.innerText.gsub(/<\/?[^>]*>/, "").strip if synopsis_nodes.any?
        parsed_values[:language] = product.search('/language/b252').first.innerText.strip
        parsed_values[:country] = ''

#        subject = product.search('').text
        parsed_values[:subject] = nil

        isbn10_node = product.search('//productidentifier/b221[text() = "02"]/../b244')
        gtin_node = product.search('//productidentifier/b221[text() = "03"]/../b244')
        isbn_node = product.search('//productidentifier/b221[text() = "15"]/../b244')
        parsed_values[:isbn10] = isbn10_node.any? ? isbn10_node.first.innerText : ''
        parsed_values[:gtin] = gtin_node.any? ? gtin_node.first.innerText : ''
        parsed_values[:isbn] = isbn_node.any? ? isbn_node.first.innerText : ''
        parsed_values[:upc] = ''

        other_isbn_node = product.search("/relatedproduct/h208[text() = '13']/../productidentifier/b244")
        parsed_values[:other_isbn] = other_isbn_node.collect(&:innerText) if other_isbn_node.any?

        file_path = "/tmp/#{parsed_values[:isbn]}.jpg"
        parsed_values[:cover] = File.exists?(file_path) ? File.new(file_path) : nil

        # prices
        prices = []
        price_nodes = product.search('/supplydetail/price')
        if price_nodes.any?
          price_nodes.each do |price_node|
            price_data = {:price => nil, :start_date => nil, :end_date => nil, :currency => nil}
            price_data[:price] = price_node.search('/j151').first.innerText if price_node.search('/j151').any?

            # PriceEffectiveFrom
            price_data[:start_date] = price_node.search("/j161").first.innerText if price_node.search("/j161").any?

            # PriceEffectiveUntil
            price_data[:end_date] = price_node.search("/j162").first.innerText if price_node.search("/j162").any?

            # CurrencyType
            price_data[:currency] = price_node.search("/j152").first.innerText if price_node.search("/j152").any?

            territory = {}

            # Region Included
            territory[:region_included] = price_node.search("/j303").any? ? price_node.search("/j303").first.innerText : ''
            # Region Excluded
            territory[:region_excluded] = price_node.search("/j305").any? ? price_node.search("/j305").first.innerText : ''
            # Country Included
            territory[:country_included] = price_node.search("/b251").any? ? price_node.search("/b251").first.innerText : ''
            # Country Excluded
            territory[:country_excluded] = price_node.search("/j304").any? ? price_node.search("/j304").first.innerText : ''
            price_data[:territory] = territory

            prices << price_data
          end
        else
          prices << {:price => 0, :start_date => nil, :end_date => nil, :region => 'WORLD', :currency => 'USD'}  
        end
        parsed_values[:prices] = prices

        excerpt_node = product.search("/othertext/d102[text() = '23']/../d104")
        parsed_values[:excerpt] = ''
        if(excerpt_node.any?)
          parsed_values[:excerpt] = excerpt_node.first.innerText
        end
        parsed_values[:xml] = product.to_s

        cover_node = product.search("/mediafile/f114[text() = '04']/../f117")
        parsed_values[:cover_url] = cover_node.first.innerText if cover_node.any?

        yield OnixParser::Product.new(parsed_values)
      end
    end
  end
end