require File.dirname(__FILE__) + '/spec_helper.rb'

describe OnixParser::Reader do
  
  before do
    @data_path = File.join(File.dirname(__FILE__), "..", "data")
    @file = File.join(@data_path, 'CrosswayEbooks.xml')
    doc = Hpricot(File.read(@file))
    @products = []
    OnixParser::Parser2long.find_products(doc) do |product|
      @products << product
    end
    @rights = @products.first.sales_rights
  end

  context 'crosswayebooks onix file' do   
    it "should have title of last book" do
      @products.last.title.should  eql('A Meal with Jesus')
    end
  end
end