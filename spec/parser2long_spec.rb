require File.dirname(__FILE__) + '/spec_helper.rb'

describe OnixParser::Parser2long do
  before(:each) do
    @data_path = File.join(File.dirname(__FILE__), "..", "data")
  end

  context 'sales_rights_long_1' do
    before do
      @file = File.join(@data_path, 'sales_rights_long_1.xml')
      doc = Hpricot(File.read(@file))
      @products = []
      OnixParser::Parser2long.find_products(doc) do |product|
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

  context 'sales_rights_long_2' do
    before do
      @file = File.join(@data_path, 'sales_rights_long_2.xml')
      doc = Hpricot(File.read(@file))
      @products = []
      OnixParser::Parser2long.find_products(doc) do |product|
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

    it "should set the released_at date" do
      @products[0].released_at.should == '20110707'
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

      it "should set the price type code" do
        @price_data[:price_type].should == '01'
      end

      it "should set the sales rights" do
        @price_data[:territory][:region_included].should == 'WORLD'

        other_price_data = @products[3].prices.first
        other_price_data[:territory][:region_excluded].should == 'ROW'
        other_price_data[:territory][:country_included].should == 'CA PH US GB'
      end
    end

    it "should set the xml" do
      (0..5).each do |n|
        @products[n].xml.should_not be_nil
      end
    end

    it "should have related ids" do
      @products[0].other_ids.count.should == 1
      @products[0].other_ids[0][0].should == 'ISBN-13'
      @products[0].other_ids[0][1].should == '9781433521546'
    end
  end
end