require File.dirname(__FILE__) + '/spec_helper.rb'

describe "parsing onix files of BH" do

  describe 'BH publishing201202021823' do
    data_path = File.join(File.dirname(__FILE__), "..", "data")
    file = File.join(data_path, "BHPublishing201202021823_RethinkBooks_Ebooks_onix21.xml")
    doc = Hpricot(File.read(file))
    products = []
    OnixParser::Parser2short.find_products(doc) do |product|
      products << product
    end
    
    products.length.should  > 0
  end
  
  describe "BH domainyyyymmddhhmm" do
    data_path = File.join(File.dirname(__FILE__), "..", "data")
    file = File.join(data_path, "DomainYYYYMMDDHHMM_Receiver_Ebooks_onix21.xml")
    doc = Hpricot(File.read(file))
    products = []
    OnixParser::Parser2short.find_products(doc) do |product|
      products << product
    end
    
    puts(products.length)
    products.length.should  > 0
  end
  
end