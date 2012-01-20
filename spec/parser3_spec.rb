require File.dirname(__FILE__) + '/spec_helper.rb'

describe OnixParser::Parser3 do
  before(:each) do
    @data_path = File.join(File.dirname(__FILE__), "..", "data")
  end

  context 'Tyndale' do
    before(:each) do
      @file = File.join(@data_path, 'sales_rights_3_1.xml')
      doc = Hpricot(File.read(@file))
      @products = []
      OnixParser::Parser3.find_products(doc) do |product|
        @products << product
      end
      @rights = @products.first.sales_rights
    end

    it 'should get the correct pricing data' do
      product = @products.first
      product.prices[0][:country].should == ['WORLD']
    end
  end
  
  context 'Sales Rights' do
    context 'sales_rights_3' do
      before(:each) do
        @file = File.join(@data_path, 'sales_rights_3.xml')
        doc = Hpricot(File.read(@file))
        @products = []
        OnixParser::Parser3.find_products(doc) do |product|
          @products << product
        end
        @rights = @products.first.sales_rights
      end

      it 'should have the sales rights' do
        @rights.count.should == 71
      end

      it 'should be sellable in the specified countries' do
        list = ["AG", "AI", "AU", "BB", "BD", "BM", "BN", "BS", "BW", "BZ", "CC", "CK", "CM", "CX", "CY", "DM", "FK", "GD", "GG", "GH", "GI", "GM", "GY", "IM", "IN", "JE", "JM", "KE", "KI", "KN", "KY", "LC", "LK", "LS", "MS", "MT", "MU", "MV", "MW", "MY", "MZ", "NA", "NF", "NG", "NR", "NU", "NZ", "PG", "PK", "PN", "SB", "SC", "SG", "SH", "SL", "SZ", "TC", "TK", "TO", "TT", "TV", "TZ", "UG", "VC", "VG", "VU", "WS", "ZA", "ZM", "ZW"]
        list.each_with_index do |value, index|
          terr = @rights[index + 1]
          terr.should_not be_nil
          terr[:country].should == value
          terr[:type].should == '03'
          terr[:sellable].should == 1
        end
      end

      it 'should not be sellable in the rest of the world' do
        row = @rights[0]
        row.should_not be_nil
        row[:country].should == 'WORLD'
        row[:type].should == '03'
        row[:sellable].should == 0
      end
    end
  end

  context "Pricing" do
    context "example 1" do
      before(:each) do
        @pricing_file = File.join(@data_path, "pricing_1_onix3.xml")
        doc = Hpricot(File.read(@pricing_file))
        @products = []
        OnixParser::Parser3.find_products(doc) do |product|
          @products << product
        end
      end

      it "should set the price appropriately" do
        price = @products[0].prices.first
        price[:price_type].should == '41'
        price[:price].should == '12.99'
        price[:currency].should == 'USD'
      end

      it "should have a related product" do
        @products[0].other_ids.count.should == 1
        @products[0].other_ids[0][1].should == '9780842300520'
      end
    end

    context "example 2" do
      before(:each) do
        @pricing_file = File.join(@data_path, "pricing_2_onix3.xml")
        doc = Hpricot(File.read(@pricing_file))
        @products = []
        OnixParser::Parser3.find_products(doc) do |product|
          @products << product
        end
      end

      it "should set the prices appropriately" do
        first_price = @products[0].prices[0]
        first_price[:price].should == '12.99'
        first_price[:currency].should == 'USD'
        first_price[:end_date].should == '20110305'
        first_price[:price_type].should == '41'

        second_price = @products[0].prices[1]
        second_price[:price].should == '8.99'
        second_price[:currency].should == 'USD'
        second_price[:start_date].should == '20110306'
        second_price[:price_type].should == '41'
      end
    end

    context "example 3" do
      before(:each) do
        @pricing_file = File.join(@data_path, "pricing_3_onix3.xml")
        doc = Hpricot(File.read(@pricing_file))
        @products = []
        OnixParser::Parser3.find_products(doc) do |product|
          @products << product
        end
      end

      it "should set the prices appropriately" do
        first_price = @products[0].prices[0]
        first_price[:price].should == '12.99'
        first_price[:currency].should == 'USD'
        first_price[:country].should == 'US'
        first_price[:price_type].should == '41'

        second_price = @products[0].prices[1]
        second_price[:price].should == '7.50'
        second_price[:currency].should == 'USD'
        second_price[:country].should == 'IN'
        second_price[:price_type].should == '01'
      end
    end

    context "example 4" do
      before(:each) do
        @pricing_file = File.join(@data_path, "pricing_4_onix3.xml")
        doc = Hpricot(File.read(@pricing_file))
        @products = []
        OnixParser::Parser3.find_products(doc) do |product|
          @products << product
        end
      end

      it "should set the prices appropriately" do
        first_price = @products[0].prices[0]
        first_price[:price].should == '9.99'
        first_price[:currency].should == 'GBP'
        first_price[:country].should == 'GB'
        first_price[:price_type].should == '42'

        second_price = @products[0].prices[1]
        second_price[:price].should == '11.99'
        second_price[:currency].should == 'USD'
        second_price[:country].should == 'US'
        second_price[:price_type].should == '41'

        third_price = @products[0].prices[2]
        third_price[:price].should == '9.50'
        third_price[:currency].should == 'EUR'
        third_price[:country].should == 'EUR'
        third_price[:price_type].should == '01'

        fourth_price = @products[0].prices[3]
        fourth_price[:price].should == '8.50'
        fourth_price[:currency].should == 'GBP'
        fourth_price[:country].should == 'WORLD'
        fourth_price[:price_type].should == '01'
      end
    end
  end

  context "books_3 file" do
    before(:each) do
      @file2 = File.join(@data_path, "books_3.xml")
      doc = Hpricot(File.read(@file2))
      @products = []
      OnixParser::Parser3.find_products(doc) do |product|
        @products << product
      end
    end

    it "should only use the first TitleElement to set the title" do
      @products[1].title.should eql('Counseling Survivors of Sexual Abuse')
    end

    it "should set multiple author/contributors" do
      @products[11].author.should eql('Charles R. Solomon,Stephen F. Olford')
    end

    it "should set the publishing_status" do
      @products[7].publishing_status.should == '04'
      @products[8].publishing_status.should == '07'
      @products[204].publishing_status.should == '01'
    end

    it "should set the released_at date" do
      @products[0].released_at.should == '19990301'
    end

    it "should set the price" do
      @products[0].prices[0][:price].should == '11.99'
      @products[0].prices[0][:start_date].should == nil
      @products[0].prices[0][:end_date].should == nil
      @products[0].prices[0][:currency].should == 'USD'
      @products[0].prices[0][:price_type].should == '01'
      @products[0].prices[0][:country].should == ['WORLD']

      @products[1].prices[0][:price].should == '24.99'
      @products[1].prices[0][:start_date].should == nil
      @products[1].prices[0][:end_date].should == nil
      @products[1].prices[0][:currency].should == 'USD'
      @products[1].prices[0][:price_type].should == '01'
      @products[1].prices[0][:country].should == ['WORLD']

      @products[2].prices[0][:price].should == '12.99'
      @products[2].prices[0][:start_date].should == nil
      @products[2].prices[0][:end_date].should == nil
      @products[2].prices[0][:currency].should == 'USD'
      @products[2].prices[0][:price_type].should == '01'
      @products[2].prices[0][:country].should == ['PH']

      @products[3].prices[0][:price].should == '10.99'
      @products[3].prices[0][:start_date].should == nil
      @products[3].prices[0][:end_date].should == nil
      @products[3].prices[0][:currency].should == 'USD'
      @products[3].prices[0][:price_type].should == '01'
      @products[3].prices[0][:country].should == ['WORLD']

      @products[4].prices[0][:price].should == '10.99'
      @products[4].prices[0][:start_date].should == nil
      @products[4].prices[0][:end_date].should == nil
      @products[4].prices[0][:currency].should == 'USD'
      @products[4].prices[0][:price_type].should == '01'
      @products[4].prices[0][:country].should == ['WORLD']

      @products[5].prices[0][:price].should == '10.99'
      @products[5].prices[0][:start_date].should == nil
      @products[5].prices[0][:end_date].should == nil
      @products[5].prices[0][:currency].should == 'USD'
      @products[5].prices[0][:price_type].should == '01'
      @products[5].prices[0][:country].should == ['WORLD']
    end
  end

  context "onix_3 file" do
    before(:each) do
      @file1 = File.join(@data_path, "onix_3.xml")
      doc = Hpricot(File.read(@file1))
      @products = []
      OnixParser::Parser3.find_products(doc) do |product|
        @products << product
      end
    end

    it "should obtain the products" do
      @products.count.should eql(6)
    end

    it "should set the title" do
      @products[0].title.should eql('The Volunteer Revolution')
      @products[1].title.should eql('Just Walk Across the Room')
      @products[2].title.should eql('Holy Discontent')
      @products[3].title.should eql('Axiom')
      @products[4].title.should eql('The Power of a Whisper')
      @products[5].title.should eql('God Unboxed')
    end

    it "should set the author" do
      (0..5).each do |n|
        @products[n].author.should eql('Bill Hybels')
      end
    end

    it "should set the subject" do
      (0..5).each do |n|
        @products[n].subject.should eql('Christian Interest')
      end
    end

    it "should set the ISBN" do
      @products[0].isbn.should eql('9780310252382')
      @products[1].isbn.should eql('9780310266693')
      @products[2].isbn.should eql('9780310272281')
      @products[3].isbn.should eql('9780310272366')
      @products[4].isbn.should eql('9780310320746')
      @products[5].isbn.should eql('9780310334132')
    end

    it "should set the ISBN-10" do
      @products[0].isbn10.should eql('0310252385')
      @products[1].isbn10.should eql('0310266696')
      @products[2].isbn10.should eql('0310272289')
      @products[3].isbn10.should eql('031027236X')
      @products[4].isbn10.should eql('0310320747')
      @products[5].isbn10.should eql('0310334136')
    end

    it "should set the UPC" do
      @products[0].upc.should eql('025986252380')
      @products[1].upc.should eql('025986266691')
      @products[2].upc.should eql('025986272289')
      @products[3].upc.should eql('025986272364')
      @products[4].upc.should eql('025986320744')
      @products[5].upc.should eql('025986334130')
    end

    it "should set the GTIN-13" do
      @products[0].gtin.should eql('9780310252382')
      @products[1].gtin.should eql('9780310266693')
      @products[2].gtin.should eql('9780310272281')
      @products[3].gtin.should eql('9780310272366')
      @products[4].gtin.should eql('9780310320746')
      @products[5].gtin.should eql('9780310334132')
    end

    it "should set the Language Code" do
      (0..5).each do |n|
        @products[n].lang.should eql('eng')
      end
    end

    it "should set the Country Code" do
      (0..5).each do |n|
        @products[n].country.should eql('US')
      end
    end

    it "should set the cover if present in the XML" do
      (0..4).each do |n|
        @products[n].cover_url.should_not == ''
      end
      @products[0].cover_url.should == 'http://www.zondervan.com/images/product/medium/0310252385.jpg'
      @products[1].cover_url.should == 'http://www.zondervan.com/images/product/medium/0310266696.jpg'
      @products[2].cover_url.should == 'http://www.zondervan.com/images/product/medium/0310272289.jpg'
      @products[3].cover_url.should == 'http://www.zondervan.com/images/product/medium/031027236x.jpg'
      @products[4].cover_url.should == 'http://www.zondervan.com/images/product/medium/0310320747.jpg'
      @products[5].cover_url.should == ''
    end

    it "should set the synopsis" do
      @products[0].synopsis.start_with?('The future of the local church').should be_true
      @products[1].synopsis.start_with?('What if you knew that by simply crossing').should be_true
      @products[2].synopsis.start_with?('What is the one aspect of this broken').should be_true
      @products[3].synopsis.start_with?('The best leaders not only lead well').should be_true
      @products[4].synopsis.start_with?("'Without a hint of exaggeration,'").should be_true
      @products[5].synopsis.start_with?('Distant Deity or intimate companion?').should be_true
    end

    it "should set the publisher" do
      (0..5).each do |n|
        @products[n].publisher.should eql('Zondervan')
      end
    end

    it "should set the price" do
      (0..5).each do |n|
        @products[n].prices.should eql([{:price => 0, :start_date => nil, :end_date => nil, :currency => 'USD'}])
      end
    end

    it "should set the xml" do
      (0..5).each do |n|
        @products[n].xml.should_not be_nil
      end
    end
  end
end