module OnixParser
  UNAVAILABLE_CODE = ["WS", "OP", "AB", "OI", "OR"]
  UNAVAILABLE_PRODUCT = ["30", "31", "34", "40", "41", "46", "49", "51", "52"]
  
  def self.product_available?(available_product, available_code=nil)
    !UNAVAILABLE_PRODUCT.include?(available_product) && !UNAVAILABLE_CODE.include?(available_code) 
  end
end