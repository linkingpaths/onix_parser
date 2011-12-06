module OnixParser
  class Parser3
    def self.find_products(doc, &block)
      doc.root.search("/Product").each do |xml_product|
        parsed_values = {}
        parsed_values[:title] = xml_product.search("/DescriptiveDetail/TitleDetail/TitleElement/TitleText").first.innerText.strip
        parsed_values[:author] = xml_product.search("/DescriptiveDetail/Contributor/PersonName").collect(&:innerText).join(',')
        parsed_values[:subject] = xml_product.search("/DescriptiveDetail/Subject/SubjectSchemeIdentifier[text() = '22']/../SubjectSchemeVersion[text() = '2.0']/../SubjectHeadingText").text.strip
        parsed_values[:language] = xml_product.search("/DescriptiveDetail/Language/LanguageCode").text.strip
        parsed_values[:country] = xml_product.search("/DescriptiveDetail/Language/CountryCode").text.strip

        parsed_values[:isbn] = xml_product.search("/ProductIdentifier/ProductIDType[text() = 15]/../IDValue").text.strip
        isbn10_node = xml_product.search("/ProductIdentifier/ProductIDType[text() = 02]/../IDValue")
        parsed_values[:isbn10] = isbn10_node.text.strip if isbn10_node.any?
        gtin_node = xml_product.search("/ProductIdentifier/ProductIDType[text() = 03]/../IDValue")
        parsed_values[:gtin] = gtin_node.text.strip if gtin_node.any?
        upc_node = xml_product.search("/ProductIdentifier/ProductIDType[text() = 04]/../IDValue")
        parsed_values[:upc] = upc_node.text.strip if upc_node.any?

        collateral_detail = xml_product.search("/CollateralDetail")
        parsed_values[:cover] = nil
        if (collateral_detail.any?)
          file_path = "/tmp/#{parsed_values[:isbn]}.jpg"
          if File.exists?(file_path)
            parsed_values[:cover] = File.new(file_path)
          else
            cover_node = collateral_detail.search("/SupportingResource/ResourceContentType[text() = '01']/../ResourceVersion/ResourceLink")

            cover_url = cover_node.any? ? cover_node.text.strip : ''
            unless (cover_url == '')
              uri = URI.parse(cover_url)
              Net::HTTP.start(uri.host) {|http|
                resp = http.get(uri.path)
                parsed_values[:cover] = Tempfile.new('book_cover')
                parsed_values[:cover].write(resp.body)
              }
            end
          end

          long_synopsis_node = collateral_detail.search("/TextContent/TextType[text() = '03']/../Text")
          parsed_values[:synopsis] = long_synopsis_node.any? ? long_synopsis_node.text.strip : ''
          short_synopsis_node = collateral_detail.search("/TextContent/TextType[text() = '02']/../Text")
          parsed_values[:synopsis] = short_synopsis_node.text.strip if parsed_values[:synopsis] == '' && short_synopsis_node.any?

        end

        parsed_values[:other_ids] = []
        related_products = xml_product.search("/RelatedMaterial/RelatedProduct/ProductRelationCode[text() = '13']/../ProductIdentifier")
        related_products.each do |related_product|
          parsed_values[:other_ids] << [find_product_type(related_product.search('/ProductIDType').first.innerText), related_product.search('/IDValue').first.innerText]
        end

        default_territory = {:region_included => '', :region_excluded => '',
                             :country_included => '', :country_excluded => ''}
        publishing_detail = xml_product.search("/PublishingDetail")
        if publishing_detail.any?
          parsed_values[:publisher] = publishing_detail.search("/Publisher/PublisherName").text.strip
          parsed_values[:publishing_status] = publishing_detail.search("/PublishingStatus").text.strip

          sales_rights_territory = publishing_detail.search("/SalesRights/Territory")
          if sales_rights_territory.any?
            default_territory[:region_included] = sales_rights_territory.search("/RegionsIncluded").first.innerText if sales_rights_territory.search("/RegionsIncluded").any?
            default_territory[:region_excluded] = sales_rights_territory.search("/RegionsExcluded").first.innerText if sales_rights_territory.search("/RegionsExcluded").any?
            default_territory[:country_included] = sales_rights_territory.search("/CountryIncluded").first.innerText if sales_rights_territory.search("/CountryIncluded").any?
            default_territory[:country_excluded] = sales_rights_territory.search("/CountryExcluded").first.innerText if sales_rights_territory.search("/CountryExcluded").any?
          end
        end

        prices = []
        product_supplies = xml_product.search("/ProductSupply")
        market_count = xml_product.search("/ProductSupply/Market").count

        if market_count > 1
          prices << self.parse_markets(product_supplies)
        else
          prices << self.parse_markets(product_supplies, default_territory)
        end

        parsed_values[:prices] = prices.flatten
        parsed_values[:xml] = xml_product.to_s

        yield OnixParser::Product.new(parsed_values)
      end
    end

    def self.parse_markets(product_supplies, default_territories = {})
      prices = []
      product_supplies.each do |product_supply|
        default_market_territories = {}
        market_territories = product_supply.search("/Market/Territory")
        if market_territories.any?
          market_territory = market_territories.first
          default_market_territories[:region_included] = market_territory.search("/RegionsIncluded").any? ? market_territory.search("/RegionsIncluded").first.innerText : ''
          default_market_territories[:region_excluded] = market_territory.search("/RegionsExcluded").any? ? market_territory.search("/RegionsExcluded").first.innerText : ''
          default_market_territories[:country_included] = market_territory.search("/CountriesIncluded").any? ? market_territory.search("/CountriesIncluded").first.innerText : ''
          default_market_territories[:country_excluded] = market_territory.search("/CountriesExcluded").any? ? market_territory.search("/CountriesExcluded").first.innerText : ''
        else
          default_market_territories[:region_included] = default_territories[:region_included]
          default_market_territories[:region_excluded] = default_territories[:region_excluded]
          default_market_territories[:country_included] = default_territories[:country_included]
          default_market_territories[:country_excluded] = default_territories[:country_excluded]
        end

        price_nodes = product_supply.search("/SupplyDetail/Price")
        if price_nodes.count > 1
          prices << self.parse_prices(price_nodes)
        else
          prices << self.parse_prices(price_nodes, default_market_territories)
        end
      end
      prices.flatten
    end

    def self.parse_prices(prices_nodes, default_territories = {})
      prices = []
      prices_nodes.each do |price_node|
        price_data = {:price => price_node.search("/PriceAmount").first.innerText, :start_date => nil, :end_date => nil}
        price_data[:currency] = price_node.search("/CurrencyCode").first.innerText if price_node.search("/CurrencyCode").any?
        price_data[:price_type] = price_node.search("/PriceType").first.innerText if price_node.search("/PriceType").any?

        territory_nodes = price_node.search("/Territory")
        currency_zone_nodes = price_node.search("/CurrencyZone")
        price_territory = {}
        if territory_nodes.any?
          territory = territory_nodes.first
          price_territory[:region_included] = territory.search("/RegionsIncluded").any? ? territory.search("/RegionsIncluded").first.innerText : ''
          price_territory[:region_excluded] = territory.search("/RegionsExcluded").any? ? territory.search("/RegionsExcluded").first.innerText : ''
          price_territory[:country_included] = territory.search("/CountriesIncluded").any? ? territory.search("/CountriesIncluded").first.innerText : ''
          price_territory[:country_excluded] = territory.search("/CountriesExcluded").any? ? territory.search("/CountriesExcluded").first.innerText : ''
        elsif currency_zone_nodes.any?
          price_territory[:currency_zone] = currency_zone_nodes.first.innerText
        else
          price_territory[:region_included] = default_territories[:region_included]
          price_territory[:region_excluded] = default_territories[:region_excluded]
          price_territory[:country_included] = default_territories[:country_included]
          price_territory[:country_excluded] = default_territories[:country_excluded]
        end

        price_data[:territory] = price_territory

        if price_node.search("/PriceDate").any?
          start_date_node = price_node.search("/PriceDate/PriceDateRole[text() = '14']/../Date")
          price_data[:start_date] = start_date_node.first.innerText if start_date_node.any?

          end_date_node = price_node.search("/PriceDate/PriceDateRole[text() = '15']/../Date")
          price_data[:end_date] = end_date_node.first.innerText if end_date_node.any?
        end
        prices << price_data
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