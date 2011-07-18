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

  it "should set the synopsis" do
    @products[0].synopsis.start_with?('This personal growth diet companion').should be_true
  end

  it "should set the publisher" do
    @products[0].publisher.should eql('Thomas Nelson')
  end

  it "should set the xml" do
    @products[0].xml.should_not be_nil
  end
  
#  it "should set the price" do
#
#  end
end