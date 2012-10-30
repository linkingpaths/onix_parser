module OnixParser
  class Parser3
    def self.parse_product(product, &block)
      parsed_values = {}
      parsed_values[:title] = product.search("/DescriptiveDetail/TitleDetail/TitleElement/TitleText").first.innerText.strip
      parsed_values[:author] = product.search("/DescriptiveDetail/Contributor/PersonName").collect(&:innerText).join(',')
      parsed_values[:subject] = product.search("/DescriptiveDetail/Subject/SubjectSchemeIdentifier[text() = '22']/../SubjectSchemeVersion[text() = '2.0']/../SubjectHeadingText").text.strip
      parsed_values[:language] = product.search("/DescriptiveDetail/Language/LanguageCode").text.strip
      parsed_values[:country] = product.search("/DescriptiveDetail/Language/CountryCode").text.strip

      parsed_values[:isbn] = product.search("/ProductIdentifier/ProductIDType[text() = 15]/../IDValue").text.strip
      isbn10_node = product.search("/ProductIdentifier/ProductIDType[text() = 02]/../IDValue")
      parsed_values[:isbn10] = isbn10_node.text.strip if isbn10_node.any?
      gtin_node = product.search("/ProductIdentifier/ProductIDType[text() = 03]/../IDValue")
      parsed_values[:gtin] = gtin_node.text.strip if gtin_node.any?
      upc_node = product.search("/ProductIdentifier/ProductIDType[text() = 04]/../IDValue")
      parsed_values[:upc] = upc_node.text.strip if upc_node.any?

      avail_product_node = product.search('/ProductSupply/SupplyDetail/ProductAvailability')
      parsed_values[:available] = OnixParser::product_available?(avail_product_node.any? ? avail_product_node.text.strip : nil)
      
      collateral_detail = product.search("/CollateralDetail")
      parsed_values[:cover] = nil
      if (collateral_detail.any?)
        file_path = "/tmp/#{parsed_values[:isbn]}.jpg"
        if File.exists?(file_path)
          parsed_values[:cover] = File.new(file_path)
        else
          cover_node = collateral_detail.search("/SupportingResource/ResourceContentType[text() = '01']/../ResourceVersion/ResourceLink")
          parsed_values[:cover_url] = cover_node.any? ? cover_node.first.innerText.strip : ''
        end

        long_synopsis_node = collateral_detail.search("/TextContent/TextType[text() = '03']/../Text")
        parsed_values[:synopsis] = long_synopsis_node.any? ? long_synopsis_node.text.strip : ''
        short_synopsis_node = collateral_detail.search("/TextContent/TextType[text() = '02']/../Text")
        parsed_values[:synopsis] = short_synopsis_node.text.strip if parsed_values[:synopsis] == '' && short_synopsis_node.any?

      end

      parsed_values[:other_ids] = []
      related_products = product.search("/RelatedMaterial/RelatedProduct/ProductRelationCode[text() = '13']/../ProductIdentifier")
      related_products.each do |related_product|
        parsed_values[:other_ids] << [find_product_type(related_product.search('/ProductIDType').first.innerText), related_product.search('/IDValue').first.innerText]
      end

      default_territory = {:region_included => [], :region_excluded => [],
                           :country_included => [], :country_excluded => []}
      publishing_detail = product.search("/PublishingDetail")
      if publishing_detail.any?
        parsed_values[:publisher] = publishing_detail.search("/Publisher/PublisherName").text.strip
        parsed_values[:publishing_status] = publishing_detail.search("/PublishingStatus").text.strip

        publish_date_node = publishing_detail.search("/PublishingDate/PublishingDateRole[text() = '01']/../Date")

        parsed_values[:released_at] = publish_date_node.first.innerText if publish_date_node.any?

        # Sales Rights
        sales_rights = []
        sales_rights_nodes = publishing_detail.search('/SalesRights')
        sales_rights_nodes.each do |node|
          type_code = node.search('/SalesRightsType').first.innerText
          sellable = ['01', '02', '07', '08'].include?(type_code) ? 1 : 0
          inverse = sellable == 1 ? 0 : 1

          node.search('/Territory/RegionsIncluded').each do |region_node|
            region_node.innerText.split(' ').each do |name|
              data = {:country => name, :sellable => sellable, :type => type_code}
              sales_rights << data
            end
          end

          node.search('/Territory/CountriesIncluded').each do |country_node|
            country_node.innerText.split(' ').each do |name|
              data = {:country => name, :sellable => sellable, :type => type_code}
              sales_rights << data
            end
          end

          node.search('/Territory/RegionsExcluded').each do |region_node|
            region_node.innerText.split(' ').each do |name|
              data = {:country => name, :sellable => inverse, :type => type_code}
              sales_rights << data
            end
          end

          node.search('/Territory/CountriesExcluded').each do |country_node|
            country_node.innerText.split(' ').each do |name|
              data = {:country => name, :sellable => inverse, :type => type_code}
              sales_rights << data
            end
          end
        end
        parsed_values[:sales_rights] = sales_rights
      end

      prices = []
      product_supplies = product.search("/ProductSupply")
      market_count = product.search("/ProductSupply/Market").count

      if market_count > 1
        prices << self.parse_markets(product_supplies, parsed_values[:sales_rights])
      else
        prices << self.parse_markets(product_supplies, parsed_values[:sales_rights], default_territory)
      end

      parsed_values[:prices] = prices.flatten

      parsed_values[:xml] = product.to_s

      yield OnixParser::Product.new(parsed_values)
    end

    def self.find_products(doc, &block)
      doc.root.search("/Product").each do |product|
        self.parse_product(product, &block)
      end
    end

    def self.parse_markets(product_supplies, sales_rights, default_territories = {})
      prices = []
      product_supplies.each do |product_supply|
        default_market_territories = {}
        market_territories = product_supply.search("/Market/Territory")
        if market_territories.any?
          market_territory = market_territories.first
          default_market_territories[:region_included] = market_territory.search("/RegionsIncluded").any? ? market_territory.search("/RegionsIncluded").collect(&:innerText) : []
          default_market_territories[:region_excluded] = market_territory.search("/RegionsExcluded").any? ? market_territory.search("/RegionsExcluded").collect(&:innerText) : []
          default_market_territories[:country_included] = market_territory.search("/CountriesIncluded").any? ? market_territory.search("/CountriesIncluded").collect(&:innerText) : []
          default_market_territories[:country_excluded] = market_territory.search("/CountriesExcluded").any? ? market_territory.search("/CountriesExcluded").collect(&:innerText) : []
        else
          default_market_territories[:region_included] = default_territories[:region_included]
          default_market_territories[:region_excluded] = default_territories[:region_excluded]
          default_market_territories[:country_included] = default_territories[:country_included]
          default_market_territories[:country_excluded] = default_territories[:country_excluded]
        end

        price_nodes = product_supply.search("/SupplyDetail/Price")
        if price_nodes.count > 1
          prices << self.parse_prices(price_nodes, sales_rights)
        else
          prices << self.parse_prices(price_nodes, sales_rights, default_market_territories)
        end
      end
      prices.flatten
    end

    def self.parse_prices(prices_nodes, sales_rights, default_territories = {})
      prices = []
      prices_nodes.each do |price_node|
        price_data = {:price => price_node.search("/PriceAmount").first.innerText, :start_date => nil, :end_date => nil}
        price_data[:currency] = price_node.search("/CurrencyCode").first.innerText if price_node.search("/CurrencyCode").any?
        price_data[:price_type] = price_node.search("/PriceType").first.innerText if price_node.search("/PriceType").any?
        
        # discount code
        discount_node = price_node.search('/DiscountCoded/DiscountCode')
        parsed_values[:percent_due_publisher] = discount_node.first.innerText if discount_node.any?

        territory_nodes = price_node.search("/Territory")
        currency_zone_nodes = price_node.search("/CurrencyZone")
        price_territory = {:region_included => [], :region_excluded => [], :country_included => [], :country_excluded => []}
        if territory_nodes.any?
          territory = territory_nodes.first
          price_territory[:region_included] = territory.search("/RegionsIncluded").any? ? territory.search("/RegionsIncluded").collect(&:innerText) : []
          price_territory[:region_excluded] = territory.search("/RegionsExcluded").any? ? territory.search("/RegionsExcluded").collect(&:innerText) : []
          price_territory[:country_included] = territory.search("/CountriesIncluded").any? ? territory.search("/CountriesIncluded").collect(&:innerText) : []
          price_territory[:country_excluded] = territory.search("/CountriesExcluded").any? ? territory.search("/CountriesExcluded").collect(&:innerText) : []
        elsif currency_zone_nodes.any?
          price_territory[:country_included] = currency_zone_nodes.collect(&:innerText)
        else
          price_territory[:region_included] = default_territories[:region_included]
          price_territory[:region_excluded] = default_territories[:region_excluded]
          price_territory[:country_included] = default_territories[:country_included]
          price_territory[:country_excluded] = default_territories[:country_excluded]
        end

        if price_node.search("/PriceDate").any?
          start_date_node = price_node.search("/PriceDate/PriceDateRole[text() = '14']/../Date")
          price_data[:start_date] = start_date_node.first.innerText if start_date_node.any?

          end_date_node = price_node.search("/PriceDate/PriceDateRole[text() = '15']/../Date")
          price_data[:end_date] = end_date_node.first.innerText if end_date_node.any?
        end

        if (price_territory[:country_included].any?)
          price_territory[:country_included].each do |country|
            prices << price_data.clone.merge(:country => country)
          end
        end
        if (price_territory[:region_included].any?)
          price_territory[:region_included].each do |country|
            prices << price_data.clone.merge(:country => country)
          end
        end

        if prices.empty? && sales_rights.any?
          sales_rights.each do |sales_right|
            prices << {:country => sales_right[:country], :price_type => price_data[:price_type], :price => price_data[:price], :currency => price_data[:currency], :percent_due_publisher => price_data[:percent_due_publisher]} if sales_right[:sellable] == 1
          end
        end
      end
      prices << {:price => 0, :start_date => nil, :end_date => nil, :currency => 'USD'} if prices.empty?
      prices
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
