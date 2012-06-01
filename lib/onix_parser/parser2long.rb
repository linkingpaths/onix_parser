module OnixParser
  class Parser2long
    def self.parse_product(product, &block)
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
      parsed_values[:publishing_status] = product.search('/PublishingStatus').text
      parsed_values[:released_at] = product.search('/PublicationDate').text

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

      avail_code_node = product.search('/SupplyDetail/AvailabilityCode')
      avail_product_node = product.search('/SupplyDetail/ProductAvailability')
 
      parsed_values[:available] = OnixParser::product_available?(avail_product_node.any? ? avail_product_node.text.strip : nil, avail_code_node.any? ? avail_code_node.text.strip : nil)

      # Sales Rights
      sales_rights = []
      sales_rights_nodes = product.search('/salesrights')
      sales_rights_nodes.each do |node|
        type_code = node.search('/salesrightstype').first.innerText
        sellable = ['01','02','07','08'].include?(type_code) ? 1 : 0

        where_nodes = node.search('/RightsCountry')
        where_nodes = node.search('/RightsTerritory') unless where_nodes.any?
        where_nodes = node.search('/RightsRegion') unless where_nodes.any?

        where_nodes.each do |where_node|
          country_list = where_node.innerText.split(' ')
          country_list.each do |country|
            data = {:country => country, :sellable => sellable, :type => type_code}
            sales_rights << data
          end
        end
      end

      not_for_sale_nodes = product.search('/notforsale')
      not_for_sale_nodes.each do |node|
        where_nodes = node.search('/RightsCountry')
        where_nodes = node.search('/RightsTerritory') unless where_nodes.any?
        where_nodes = node.search('/RightsRegion') unless where_nodes.any?

        where_nodes.each do |where_node|
          country_list = where_node.innerText.split(' ')
          country_list.each do |country|
            data = {:country => country, :sellable => 0, :type => '03'}
            sales_rights << data
          end
        end
      end

      parsed_values[:sales_rights] = sales_rights

      # Prices
      prices = []
      price_nodes = product.search('/SupplyDetail/Price')
      if price_nodes.any?

        price_nodes.each do |price_node|
          price_data = {:price => nil, :start_date => nil, :end_date => nil, :currency => @default_currency}
          price_data[:price] = price_node.search('/PriceAmount').first.innerText if price_node.search('/PriceAmount').any?
          # PriceEffectiveFrom
          price_data[:start_date] = price_node.search('/PriceEffectiveFrom').first.innerText if price_node.search('/PriceEffectiveFrom').any?

          # PriceEffectiveUntil
          price_data[:end_date] = price_node.search('/PriceEffectiveUntil').first.innerText if price_node.search('/PriceEffectiveUntil').any?

          # CurrencyType
          price_data[:currency] = price_node.search('/CurrencyCode').first.innerText if price_node.search('/CurrencyCode').any?

          # PriceType
          price_data[:price_type] = price_node.search('/PriceTypeCode').first.innerText if price_node.search('/PriceTypeCode').any?

          # DiscountCode
          discount_node = price_node.search('/DiscountCoded/DiscountCode')
          price_data[:percent_due_publisher] = discount_node.first.innerText if discount_node.any?

          region_in = price_node.search('/Territory')
          region_out = price_node.search('/TerritoryExcluded')
          country_in = price_node.search('/Country')
          country_out = price_node.search('/CountryExcluded')

          territory = {:region_included => [], :region_excluded => [], :country_included => [], :country_excluded => []}
          if region_in.any? || region_out.any? || country_in.any? || country_out.any?
            # Region included
            territory[:region_included] = region_in.any? ? region_in.collect(&:innerText) : []
            # Region excluded
            territory[:region_excluded] = region_out.any? ? region_out.collect(&:innerText) : []
            # Country Included
            territory[:country_included] = country_in.any? ? country_in.collect(&:innerText) : []
            # Country Excluded
            territory[:country_excluded] = country_out.any? ? country_out.collect(&:innerText) : []
          end

          territory[:country_included].each do |country|
            prices << price_data.clone.merge(:country => country)
          end
          territory[:region_included].each do |country|
            prices << price_data.clone.merge(:country => country)
          end
          if prices.empty? && sales_rights.any?
            sales_rights.each do |sales_right|
              prices << {:country => sales_right[:country], :price_type => price_data[:price_type], :price => price_data[:price], :currency => price_data[:currency], :percent_due_publisher => price_data[:percent_due_publisher]} if sales_right[:sellable] == 1
            end
          end
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

    def self.find_products(doc, &block)
      doc.root.search('/Product').each do |product|
        @default_currency = doc.root.search('/Header/DefaultCurrencyCode').any? ? doc.root.search('/Header/DefaultCurrencyCode').first.innerText : nil
        self.parse_product(product, &block)
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
