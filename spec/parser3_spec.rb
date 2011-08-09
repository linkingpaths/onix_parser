require File.dirname(__FILE__) + '/spec_helper.rb'

describe OnixParser::Parser3 do
  before(:each) do
    @data_path = File.join(File.dirname(__FILE__), "..", "data")
  end

  context "books_3 file" do
    before(:each) do
      @file2 = File.join(@data_path, "books_3.xml")
      doc = Hpricot(File.read(@file2))
      @products = OnixParser::Parser3.find_products(doc)
    end

    it "should only use the first TitleElement to set the title" do
      @products[1].title.should eql('Counseling Survivors of Sexual Abuse')
    end

    it "should set multiple author/contributors" do
      @products[11].author.should eql('Charles R. Solomon,Stephen F. Olford')
    end
  end

  context "onix_3 file" do
    before(:each) do
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

    it "should set the xml" do
      (0..5).each do |n|
        @products[n].xml.should_not be_nil
      end
    end
  end

#  it "should set the price" do
#
#  end
end