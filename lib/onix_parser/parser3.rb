module OnixParser
  class Parser3
    def self.find_products(doc)
      products = []
      doc.root.search("/Product").each do |xml_product|
        title = xml_product.search("/DescriptiveDetail/TitleDetail/TitleElement/TitleText").text.strip
        author = xml_product.search("/DescriptiveDetail/Contributor/PersonName").text.strip
        subject = xml_product.search("/DescriptiveDetail/Subject/SubjectSchemeIdentifier[text() = '22']/../SubjectSchemeVersion[text() = '2.0']/../SubjectHeadingText").text.strip

        isbn = xml_product.search("/ProductIdentifier/ProductIDType[text() = 15]/../IDValue").text.strip
        isbn = xml_product.search("/ProductIdentifier/ProductIDType[text() = 02]/../IDValue").text.strip unless isbn.any?
        
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

        products << OnixParser::Product.new(title, author, subject, publisher, cover, synopsis, isbn, xml_product.to_s)
      end

      products
    end
  end
end