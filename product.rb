require_relative 'html'
require 'csv'

class Product
  include HTML
  def initialize(product_url)
    @product_html = get_html(product_url)
    @title = @product_html.xpath("//h1[@class='product_main_name']/text()")
    @img = @product_html.xpath("//img[@id='bigpic']/@src")
  end

  def get_product_variations
    @product_variations = []
    @product_html.xpath("//ul[@class='attribute_radio_list pundaline-variations']//label").each do |option|
      product_option = option.at_xpath("span[@class='radio_label']/text()")
      product_price = option.at_xpath('span[@class="price_comb"]/text()')
      variation = ["#{@title}- #{product_option}", product_price, @img]
      @product_variations.push(variation)
    end
    self
  end

  def write_variations_to_file(filename)
    CSV.open(filename, 'a+') do |csv|
      @product_variations.each do |variation|
        csv << variation
      end
    end
    puts "Written | #{@title}"
  end
end