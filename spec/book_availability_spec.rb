require File.dirname(__FILE__) + '/spec_helper.rb'

describe "book availability for onixpaser2short" do
  context "2.1 short onix parser availability for onix_short_availiability" do
    before do
      @data_path = File.join(File.dirname(__FILE__), "..", "data")
      @file = File.join(@data_path, "onix_short_availiability.cot")
      doc = Hpricot(File.read(@file))
      @products = []
      OnixParser::Parser2short.find_products(doc) do |product|
        @products << product
      end
    end
  
    it "the first product should be available" do
      @products[0].available?.should be_true
    end
  
    it "the second product should not be available" do
      @products[1].available?.should be_false
    end
    
    it "the 3rd product should be available" do
      @products[2].available?.should be_true
    end
    
    it "the 4th product should not be available" do
      @products[3].available?.should be_false
    end
    
  end
  
  context "2.1 long onix parser availability" do
    before do
      @data_path = File.join(File.dirname(__FILE__), "..", "data")
      @file = File.join(@data_path, "CrosswayEbooks.xml")
      doc = Hpricot(File.read(@file))
      @products = []
      OnixParser::Parser2long.find_products(doc) do |product|
        @products << product
      end
    end
    
    it "the first product should be available" do
      @products[0].available?.should be_true
    end
    
    it "the 2nd product should not be available" do
      @products[1].available?.should be_false
    end
    
    it "the 3nd product should be available" do
      @products[2].available?.should be_true
    end
    
    it "the 4th product should be available" do
      @products[3].available?.should be_true
    end
    
    it "the 5th product should not be available" do
      @products[4].available?.should be_false
    end
  end
  
  context "3.0 onix parser availability" do
    before do
      @data_path = File.join(File.dirname(__FILE__), "..", "data")
      @file = File.join(@data_path, "onix_3_availiability.xml")
      doc = Hpricot(File.read(@file))
      @products = []
      OnixParser::Parser3.find_products(doc) do |product|
        @products << product
      end
    end
    
    it "the first product should be available" do
      @products[0].available?.should be_true
    end
    
    it "the 2nd product should not be available" do
      @products[1].available?.should be_false
    end
    
    it "the 3nd product should be available" do
      @products[2].available?.should be_true
    end
    
    it "the 4th product should not be available" do
      @products[3].available?.should be_false
    end
  end
end