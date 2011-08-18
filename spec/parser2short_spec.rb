require File.dirname(__FILE__) + '/spec_helper.rb'

describe OnixParser::Parser2short do
  before(:each) do
    @data_path = File.join(File.dirname(__FILE__), "..", "data")
  end

  context "related file" do
    before(:each) do
      @related = File.join(@data_path, "related.xml")
      doc = Hpricot(File.read(@related))
      @products = OnixParser::Parser2short.find_products(doc)
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
      @products = OnixParser::Parser2short.find_products(doc)
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
      @products = OnixParser::Parser2short.find_products(doc)
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

    # Have not yet identified how to pull the subject from ONIX 2.1
#  it "should set the subject" do
#    @products[0].subject.should eql("")
#  end

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
      @products[0].prices.should eql [{:price => '14.99', :start_date => nil, :end_date => nil}]
    end

    it "should set the xml" do
      @products[0].xml.should_not be_nil
    end
  end


end