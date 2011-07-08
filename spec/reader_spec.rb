require File.dirname(__FILE__) + '/spec_helper.rb'

describe OnixParser::Reader do
  before(:each) do
    @data_path = File.join(File.dirname(__FILE__), "..", "data")
    @onix3 = File.join(@data_path, "onix_3.xml")
    @onix2_short = File.join(@data_path, "short_tags.xml")
  end

  it "should initialize with a filename" do
    reader = OnixParser::Reader.new(@onix3)
    reader.instance_variable_get("@doc").should be_a_kind_of(Hpricot::Doc)
  end

  it "should initialize with an IO object" do
    File.open(@onix3,"rb") do |f|
      reader = OnixParser::Reader.new(f)
      reader.instance_variable_get("@doc").should be_a_kind_of(Hpricot::Doc)
    end
  end

  context "Onix 3.0 file" do
    it "should use the Onix 3.0 parser" do
      reader = OnixParser::Reader.new(@onix3)
      reader.instance_variable_get("@onix_parser").should eql(OnixParser::Parser3)
    end

    it "should iterate over all product records in an ONIX file" do
      reader = OnixParser::Reader.new(@onix3)
      counter = 0
      reader.each do |product|
        product.should be_a_kind_of(OnixParser::Product)
        counter += 1
      end

      counter.should eql(6)
    end
  end

  context "Onix 2.1 file" do
    it "should use the Onix 2.1 short tag parser" do
      reader = OnixParser::Reader.new(@onix2_short)
      reader.instance_variable_get("@onix_parser").should eql(OnixParser::Parser2short)
    end

    it "should iterate over all product records in an ONIX file" do
      reader = OnixParser::Reader.new(@onix2_short)
      counter = 0
      reader.each do |product|
        product.should be_a_kind_of(OnixParser::Product)
        counter += 1
      end

      counter.should eql(1)
    end
  end

end