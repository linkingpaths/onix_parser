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

        # Prices
        prices = []
        price_nodes = product.search('/SupplyDetail/Price')
        if price_nodes.any?
          default_currency = doc.root.search('/Header/DefaultCurrencyCode').any? ? doc.root.search('/Header/DefaultCurrencyCode').first.innerText : nil
          price_nodes.each do |price_node|
            price_data = {:price => nil, :start_date => nil, :end_date => nil, :currency => default_currency}
            price_data[:price] = price_node.search('/PriceAmount').first.innerText if price_node.search('/PriceAmount').any?
            price_data[:currency] = price_node.search('/CurrencyCode').first.innerText if price_node.search('/CurrencyCode').any?
            prices << price_data
          end
        end
        parsed_values[:prices] = prices

        # Related Products
        parsed_values[:other_ids] = []
        product.search('/RelatedProduct').each do |rproduct|
          parsed_values[:other_ids] << [find_product_type(rproduct.search('/ProductIdentifier/ProductIDType').first.innerText), rproduct.search('/ProductIdentifier/IDValue').first.innerText]
        end

        parsed_values[:xml] = product.to_s

        yield OnixParser::Product.new(parsed_values)
      end
    end

    def self.find_product_type(id)
      types = {'01' => 'Proprietary',
               '02' => 'ISBN-10',
               '03' => 'GTIN-13',
               '04' => 'UPC',
               '05' => 'ISMN-10',
               '06' => 'DOI',
               '13' => 'LCCN',
               '14' => 'GTIN-14',
               '15' => 'ISBN-13',
               '17' => 'Legal Deposit number',
               '22' => 'URN',
               '23' => 'OCLC number',
               '24' => "Co-publisher's ISBN-13",
               '25' => 'ISMN-13'
      }

      types[id]
    end

  end
end