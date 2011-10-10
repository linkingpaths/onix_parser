require File.dirname(__FILE__) + '/spec_helper.rb'

describe OnixParser::Parser3 do
  before(:each) do
    @data_path = File.join(File.dirname(__FILE__), "..", "data")
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
        price[:price].should == '12.99'
        price[:currency].should == 'USD'
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

        second_price = @products[0].prices[1]
        second_price[:price].should == '8.99'
        second_price[:currency].should == 'USD'
        second_price[:start_date].should == '20110306'
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
        first_price[:territory][:country_included].should == 'US'

        second_price = @products[0].prices[1]
        second_price[:price].should == '7.50'
        second_price[:currency].should == 'USD'
        second_price[:territory][:country_included].should == 'IN'

        third_price = @products[0].prices[2]
        third_price[:price].should == '12.99'
        third_price[:currency].should == 'USD'
        third_price[:territory][:region_included].should == 'WORLD'
        third_price[:territory][:country_excluded].should == 'US IN'
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
        first_price[:territory][:country_included].should == 'GB'

        second_price = @products[0].prices[1]
        second_price[:price].should == '11.99'
        second_price[:currency].should == 'USD'
        second_price[:territory][:country_included].should == 'US'

        third_price = @products[0].prices[2]
        third_price[:price].should == '9.50'
        third_price[:currency].should == 'EUR'
        third_price[:territory][:currency_zone].should == 'EUR'

        fourth_price = @products[0].prices[3]
        fourth_price[:price].should == '8.50'
        fourth_price[:currency].should == 'GBP'
        fourth_price[:territory][:region_included].should == 'WORLD'
        fourth_price[:territory][:country_excluded].should == 'US GB AT BE CY DE ES FI FR GR IE IT LU NL MT PT SI SK'
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

    it "should set the price" do
      @products[0].prices.should eql [{:price => '11.99', :start_date => nil, :end_date => nil, :currency => 'USD',
                                       :territory => {:region_included => 'WORLD',
                                                        :region_excluded => '',
                                                        :country_included => '',
                                                        :country_excluded => ''}}]


      @products[1].prices.should eql [{:price => '24.99', :start_date => nil, :end_date => nil, :currency => 'USD',
                                       :territory => {:region_included => 'WORLD',
                                                        :region_excluded => '',
                                                        :country_included => '',
                                                        :country_excluded => ''}}]
      @products[2].prices.should eql [{:price => '12.99', :start_date => nil, :end_date => nil, :currency => 'USD',
                                       :territory => {:region_included => 'WORLD',
                                                        :region_excluded => '',
                                                        :country_included => '',
                                                        :country_excluded => ''}}]
      @products[3].prices.should eql [{:price => '10.99', :start_date => nil, :end_date => nil, :currency => 'USD',
                                       :territory => {:region_included => 'WORLD',
                                                        :region_excluded => '',
                                                        :country_included => '',
                                                        :country_excluded => ''}}]
      @products[4].prices.should eql [{:price => '10.99', :start_date => nil, :end_date => nil, :currency => 'USD',
                                       :territory => {:region_included => 'WORLD',
                                                        :region_excluded => '',
                                                        :country_included => '',
                                                        :country_excluded => ''}}]
      @products[5].prices.should eql [{:price => '10.99', :start_date => nil, :end_date => nil, :currency => 'USD',
                                       :territory => {:region_included => 'WORLD',
                                                        :region_excluded => '',
                                                        :country_included => '',
                                                        :country_excluded => ''}}]
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
        @products[n].cover.should_not be_nil
      end
      @products[5].cover.should_not nil
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