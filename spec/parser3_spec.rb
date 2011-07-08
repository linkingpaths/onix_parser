require File.dirname(__FILE__) + '/spec_helper.rb'

describe OnixParser::Parser3 do
  before(:each) do
    @data_path = File.join(File.dirname(__FILE__), "..", "data")
    @file1 = File.join(@data_path, "onix_3.xml")
    doc = Hpricot(File.read(@file1))
    @products = OnixParser::Parser3.find_products(doc)
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

#  it "should set the price" do
#
#  end
end