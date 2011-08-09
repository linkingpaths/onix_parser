require File.dirname(__FILE__) + '/spec_helper.rb'

describe OnixParser::Parser2short do
  before(:each) do
    @data_path = File.join(File.dirname(__FILE__), "..", "data")
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