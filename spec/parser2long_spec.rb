require File.dirname(__FILE__) + '/spec_helper.rb'

describe OnixParser::Parser2long do
  before(:each) do
    @data_path = File.join(File.dirname(__FILE__), "..", "data")
  end

  context "onix_2_long file" do
    before(:each) do
      @onix_long = File.join(@data_path, "onix_2_long.xml")
      doc = Hpricot(File.read(@onix_long))
      @products = []
      OnixParser::Parser2long.find_products(doc) do |product|
        @products << product
      end
    end

    it "should obtain the products" do
      @products.count.should == 6
    end

    it "should set the title" do
      @products[0].title.should == 'King Solomon'
      @products[1].title.should == "Don't Call It a Comeback (Foreword by D. A. Carson)"
      @products[2].title.should == 'ePub-The Four Holy Gospels'
      @products[3].title.should == 'Pollution and the Death of Man'
      @products[4].title.should == 'To Know and Love God'
      @products[5].title.should == 'Practicing Affirmation (Foreword by John Piper)'
    end

    it "should set the author" do
      @products[0].author.should == 'Philip Graham Ryken'
      @products[1].author.should == 'Kevin DeYoung,D. A. Carson,Ted Kluck,Russell D. Moore,Tullian Tchividjian,Tim Challies,Justin Taylor,Collin Hansen,Jonathan Leeman,Greg Gilbert,Owen Strachan,Thabiti M. Anyabwile,Denny Burk,Jay Harvey,David Mathis,Andrew David Naselli,Darrin Patrick,Ben Peays,Eric C. Redmond'
      @products[2].author.should be_nil
      @products[3].author.should == 'Francis A. Schaeffer,Udo W. Middelmann,Lynn White Jr.,Richard Means'
      @products[4].author.should == 'David K. Clark,John S. Feinberg'
      @products[5].author.should == 'Sam Crabtree,John Piper'
    end

    it "should set the ISBN" do
      @products[0].isbn.should eql('9781433521676')
      @products[1].isbn.should eql('9781433521713')
      @products[2].isbn.should eql('9781433529962')
      @products[3].isbn.should eql('9781433519505')
      @products[4].isbn.should eql('9781433508769')
      @products[5].isbn.should eql('9781433522468')
    end

    it "should set the ISBN-10" do
      @products[0].isbn10.should eql('1433521679')
      @products[1].isbn10.should eql('1433521717')
      @products[2].isbn10.should eql('1433529963')
      @products[3].isbn10.should eql('143351950X')
      @products[4].isbn10.should eql('1433508761')
      @products[5].isbn10.should eql('1433522462')
    end

    it "should set the GTIN-13" do
      @products[0].gtin.should eql('9781433521676')
      @products[1].gtin.should eql('9781433521713')
      @products[2].gtin.should eql('9781433529962')
      @products[3].gtin.should eql('9781433519505')
      @products[4].gtin.should eql('9781433508769')
      @products[5].gtin.should eql('9781433522468')
    end

    it "should set the publisher" do
      (0..5).each do |n|
        @products[n].publisher.should eql('Crossway')
      end
    end

    it "should set the synopsis" do
      @products[0].synopsis.start_with?('Tracing King Solomon').should be_true
      @products[1].synopsis.start_with?('Unites some of today').should be_true
      @products[2].synopsis.should be_nil
      @products[3].synopsis.start_with?('Schaeffer&rsquo;s important classic').should be_true
      @products[4].synopsis.should be_nil
      @products[5].synopsis.start_with?('Commending what&rsquo;s commendable').should be_true
    end

    describe "Prices" do
      before(:each) do
        @price_data = @products[0].prices.first
      end

      it "should set the currency type" do
        @price_data[:currency].should == 'USD'
      end

      it "should set the start/end dates" do
        @price_data[:start_date].should be_nil
        @price_data[:end_date].should be_nil
      end

      it "should set the price amount" do
        @price_data[:price].should == '9.99'
      end
    end

    it "should set the xml" do
      (0..5).each do |n|
        @products[n].xml.should_not be_nil
      end
    end
  end
end