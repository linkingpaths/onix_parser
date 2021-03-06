require File.dirname(__FILE__) + '/spec_helper.rb'

describe OnixParser::Parser2short do
  before(:each) do
    @data_path = File.join(File.dirname(__FILE__), "..", "data")
  end

  context 'pearson' do
    before do
      @file = File.join(@data_path, 'pearson.xml')
      doc = Hpricot(File.read(@file))
      @products = []
      OnixParser::Parser2short.find_products(doc) do |product|
        @products << product
      end
    end

    it 'should have a price' do
      price_data = @products[0].prices.first
      price_data.should_not be_nil
      price_data[:price].should == '69.99'
      price_data[:currency].should == 'USD'
      price_data[:country].should == 'ROW'
      price_data[:percent_due_publisher].should == 25
    end
  end

  context 'sales_rights_1 file' do
    before do
      @file = File.join(@data_path, 'sales_rights_1.xml')
      doc = Hpricot(File.read(@file))
      @products = []
      OnixParser::Parser2short.find_products(doc) do |product|
        @products << product
      end
      @rights = @products.first.sales_rights
    end

    it 'should have the sales rights' do
      @rights.count.should == 5
    end

    it 'should not be for sale in Nigeria' do
      nigeria = @rights[0]
      nigeria.should_not be_nil
      nigeria[:country].should == 'NG'
      nigeria[:type].should == '03'
      nigeria[:sellable].should == 0
    end

    it 'should be for sale in the US, GB, CA, and AU' do
      us = @rights[1]
      us.should_not be_nil
      us[:country].should == 'US'
      us[:type].should == '01'
      us[:sellable].should == 1

      gb = @rights[2]
      gb.should_not be_nil
      gb[:country].should == 'GB'
      gb[:type].should == '01'
      gb[:sellable].should == 1

      ca = @rights[3]
      ca.should_not be_nil
      ca[:country].should == 'CA'
      ca[:type].should == '01'
      ca[:sellable].should == 1

      au = @rights[4]
      au.should_not be_nil
      au[:country].should == 'AU'
      au[:type].should == '01'
      au[:sellable].should == 1
    end


  end

  context 'sales_rights_2 file' do
    before do
      @file = File.join(@data_path, 'sales_rights_2.xml')
      doc = Hpricot(File.read(@file))
      @products = []
      OnixParser::Parser2short.find_products(doc) do |product|
        @products << product
      end
      @rights = @products.first.sales_rights
    end

    it 'should have the sales rights' do
      @rights.count.should == 21
    end

    it 'should be sellable in the rest of the world' do
      row = @rights[0]
      row.should_not be_nil
      row[:country].should == 'ROW'
      row[:type].should == '01'
      row[:sellable].should == 1
    end

    it 'should not be sellable in the specified countries' do
      list = ["AF", "DZ", "BY", "BA", "CG", "CD", "CI", "CU", "ID", "IR", "IQ", "KP", "LR", "LY", "MK", "MM", "NG", "SD", "SY", "ZW"]
      list.each_with_index do |value, index|
        terr = @rights[index + 1]
        terr.should_not be_nil
        terr[:country].should == value
        terr[:type].should == '03'
        terr[:sellable].should == 0
      end
    end
  end

  context 'selling_onix_2_short file' do
    before do
      @file = File.join(@data_path, 'selling_onix_2_short.xml')
      doc = Hpricot(File.read(@file))
      @products = []
      OnixParser::Parser2short.find_products(doc) do |product|
        @products << product
      end
    end

    it 'should have 1 price record per country' do
      product = @products.first
      product.prices.count.should == 3
      product.prices[0][:country].should == 'CA'
      product.prices[1][:country].should == 'MX'
      product.prices[2][:country].should == 'US'
    end
  end

  context "mult_prices file" do
    before(:each) do
      @multiple_prices = File.join(@data_path, "mult_prices_onix_2_short.xml")
      doc = Hpricot(File.read(@multiple_prices))
      @products = []
      OnixParser::Parser2short.find_products(doc) do |product|
        @products << product
      end
    end

    it "should set the released_at date" do
      @products[0].released_at.should == '20100831'
    end

    it "should have two price records" do
      @products[0].prices.count.should == 2
    end

    it "should have 1 price with no dates" do
      first_price = @products[0].prices[0]
      first_price[:start_date].should be_nil
      first_price[:end_date].should be_nil
      first_price[:country].should == 'WORLD'
      first_price[:currency].should == 'USD'
    end

    it "should have 1 price with start and end dates" do
      second_price = @products[0].prices[1]
      second_price[:start_date].should == '20110801'
      second_price[:end_date].should == '20110831'
      second_price[:country].should == 'WORLD'
      second_price[:currency].should == 'USD'
    end

    it "should have a workidentifier for the first product" do
      @products[0].other_ids.count.should == 1
      @products[0].other_ids[0][1].should == '9781595548047'
    end
  end


  context "related file" do
    before(:each) do
      @related = File.join(@data_path, "related.xml")
      doc = Hpricot(File.read(@related))
      @products = []
      OnixParser::Parser2short.find_products(doc) do |product|
        @products << product
      end
    end

    it "should populate the other_isbn field" do
      @products[0].isbn.should eql "9781418586560"
      @products[0].other_isbn.should eql ["9781418526542"]
    end
  end

  context "simon file" do
    before(:each) do
      @simon = File.join(@data_path, "simon.xml")
      doc = Hpricot(File.read(@simon))
      @products = []
      OnixParser::Parser2short.find_products(doc) do |product|
        @products << product
      end
    end

    it "should set the excerpt" do
      @products[0].excerpt.start_with?("\n<b><center><b>CHAPTER ONE</b></center></b> <P><b>W</b>hile").should be_true
      @products[1].excerpt.start_with?("\n<body> <p align=\"center\"> <b> <b><br/>Monster Attack!").should be_true
      @products[2].excerpt.should eql('')
      @products[3].excerpt.should eql('')
      @products[4].excerpt.should eql('')
      @products[5].excerpt.start_with?("\n<b><big><center> Chapter One </center></big></b>").should be_true
      @products[14].excerpt.start_with?("\n<body> <p align=\"center\"> <b> <b> <I>Prologue</i>").should be_true
      @products[16].excerpt.start_with?("\n<body><p align=\"center\"><b><br/><b>CHAPTER<br/>1").should be_true
      @products[17].excerpt.start_with?("\n<b><center><b>PROLOGUE</b></center></b> <P><b><center><b>Charl").should be_true
    end

    it "should set the cover_url" do
      @products[0].cover_url.should eql('http://www.netread.com/jcusers2/1247/740/9781416575740/image/lgcover.9781416575740.jpg')
      @products[1].cover_url.should eql('http://www.netread.com/jcusers2/1247/872/9781442419872/image/lgcover.9781442419872.jpg')
    end

    it "should set the isbn, isbn10 and gtin13 correctly" do
      @products[0].isbn.should eql('9781416575740')
      @products[0].isbn10.should eql('141657574X')
      @products[0].gtin.should eql('9781416575740')
    end
  end
  
  context "short_tags file" do
    before(:each) do
      @file1 = File.join(@data_path, "short_tags.xml")
      doc = Hpricot(File.read(@file1))
      @products = []
      OnixParser::Parser2short.find_products(doc) do |product|
        @products << product
      end
    end

    it "should obtain the products" do
      @products.count.should eql(1)
    end

    it "should set the title" do
      @products[0].title.should eql("100 Days of Weight Loss")
    end

    it "should set the author" do
      @products[0].author.should eql("Linda Spangle")
    end

    it "should set the ISBN" do
      @products[0].isbn.should eql("9781418573102")
    end

    it "should set the ISBN-10" do
      @products[0].isbn10.should eql('')
    end

    it "should set the GTIN-13" do
      @products[0].gtin.should eql('')
    end

    it "should set the UPC" do
      @products[0].upc.should eql('')
    end

    it "should set the language" do
      @products[0].lang.should eql('eng')
    end

    it "should se the country" do
      @products[0].country.should eql('')
    end

    it "should set the synopsis" do
      @products[0].synopsis.start_with?('This personal growth diet companion').should be_true
    end

    it "should set the publisher" do
      @products[0].publisher.should eql('Thomas Nelson')
    end

    it "should set the price" do
      @products[0].prices[0][:price].should == '14.99'
      @products[0].prices[0][:start_date].should == nil
      @products[0].prices[0][:end_date].should == nil
      @products[0].prices[0][:currency].should == 'USD'
      @products[0].prices[0][:price_type].should == '01'
      @products[0].prices[0][:country].should == 'WORLD'
    end

    it "should set the xml" do
      @products[0].xml.should_not be_nil
    end
  end
end
