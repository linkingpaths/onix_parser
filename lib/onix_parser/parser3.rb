module OnixParser
  class Parser3
    def self.find_products(doc)
      products = []
      doc.root.search("/Product").each do |xml_product|
        title = xml_product.search("/DescriptiveDetail/TitleDetail/TitleElement/TitleText").first.innerText.strip
        author = xml_product.search("/DescriptiveDetail/Contributor/PersonName").collect(&:innerText).join(',')
        subject = xml_product.search("/DescriptiveDetail/Subject/SubjectSchemeIdentifier[text() = '22']/../SubjectSchemeVersion[text() = '2.0']/../SubjectHeadingText").text.strip
        language = xml_product.search("/DescriptiveDetail/Language/LanguageCode").text.strip
        country = xml_product.search("/DescriptiveDetail/Language/CountryCode").text.strip

        isbn = xml_product.search("/ProductIdentifier/ProductIDType[text() = 15]/../IDValue").text.strip
        isbn10_node = xml_product.search("/ProductIdentifier/ProductIDType[text() = 02]/../IDValue")
        isbn10 = isbn10_node.text.strip if isbn10_node.any?
        gtin_node = xml_product.search("/ProductIdentifier/ProductIDType[text() = 03]/../IDValue")
        gtin = gtin_node.text.strip if gtin_node.any?
        upc_node = xml_product.search("/ProductIdentifier/ProductIDType[text() = 04]/../IDValue")
        upc = upc_node.text.strip if upc_node.any?

        collateral_detail = xml_product.search("/CollateralDetail")
        cover = nil
        if (collateral_detail.any?)
          file_path = "/tmp/#{isbn}.jpg"
          if File.exists?(file_path)
            cover = File.new(file_path)
          else
            cover_node = collateral_detail.search("/SupportingResource/ResourceContentType[text() = '01']/../ResourceVersion/ResourceLink")

            cover_url = cover_node.any? ? cover_node.text.strip : ''
            unless (cover_url == '')
              uri = URI.parse(cover_url)
              Net::HTTP.start(uri.host) {|http|
                resp = http.get(uri.path)
                cover = Tempfile.new('book_cover')
                cover.write(resp.body)
              }
            end
          end

          long_synopsis_node = collateral_detail.search("/TextContent/TextType[text() = '03']/../Text")
          synopsis = long_synopsis_node.any? ? long_synopsis_node.text.strip : ''
          short_synopsis_node = collateral_detail.search("/TextContent/TextType[text() = '02']/../Text")
          synopsis = short_synopsis_node.text.strip if synopsis == '' && short_synopsis_node.any?

        end

        publisher = xml_product.search("/PublishingDetail/Publisher/PublisherName").text.strip

        # TODO: PRICE
        prices = []
        price_nodes = xml_product.search("/ProductSupply/SupplyDetail/Price")
        if price_nodes.any?
          price_nodes.each do |price_node|
            price_data = {:price => price_node.search("/PriceAmount").first.innerText, :start_date => nil, :end_date => nil}
            if price_node.search("/PriceDate").any?
              # Placeholder for when we have multiple prices to deal with
            end
            prices << price_data
          end
        else
          prices << {:price => 0, :start_date => nil, :end_date => nil}
        end
        
        products << OnixParser::Product.new(title, author, subject, publisher, cover, synopsis, isbn, isbn10, gtin, upc, language, country, prices, xml_product.to_s)
      end

      products
    end
  end
end