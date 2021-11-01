# frozen_string_literal: true

require 'nokogiri'
require 'curb'
require 'csv'
require 'yaml'

module HTML
  def get_html(url)
    html = ''
    t = Thread.new do
      html_file = Curl.get(url) do |curl|
        curl.ssl_verify_peer = false
        curl.ssl_verify_host = 0
      end
      html = Nokogiri::HTML(html_file.body_str)
    end
    t.join
    html
  end

  def get_next_page_html(url, page_num)
    get_html(url + "?p=#{page_num}") if page_num > 1
  end
end

class Product
  include HTML
  def initialize(product_url)
    @product_html = get_html(product_url)
    @title = @product_html.xpath("//h1[@class='product_main_name']/text()")
    @img = @product_html.xpath("//img[@id='bigpic']/@src")
  end

  def write_variations_to_file(filename)
    CSV.open(filename, 'a+') do |csv|
      @product_html.xpath("//ul[@class='attribute_radio_list pundaline-variations']//label").each do |product_option|
        csv << ["#{@title}- #{product_option.at_xpath("span[@class='radio_label']/text()")}",
                  product_option.at_xpath("span[@class='price_comb']/text()"), @img]
      end
    end
    puts "Written | #{@title}"
  end
end

class Parser
  include HTML
  def initialize(url)
    @url = url
    @html = get_html(url)
    @pages_count = get_pages_count
  end

  def parse_to(filename)
    (1..@pages_count).each do |page_num|
      @html = get_next_page_html(@url, page_num) if page_num > 1
      @html.xpath("//div[@class='pro_first_box ']//@href").each do |product_url|
        Product.new(product_url).write_variations_to_file(filename)
      end
      puts "#{page_num} page of products written"
    end
  end

  def get_pages_count
    products_count = @html.xpath("//input[@id='nb_item_bottom']/@value").to_s
    print 'Pages: '
    puts pages = (products_count.to_i / 25.0).ceil
    pages
  end
end

module YAML
  def create_yaml(array)
    yaml_obj = YAML.dump(array)
    File.open('parameters.yml', 'w+') do |f|
      f.write(yaml_obj)
    end
  end

  def parameters_for_yaml
    print 'Category link: '
    puts e_url = 'https://www.petsonic.com/carnilove/' # "https://www.petsonic.com/pienso-ownat-perros/"
    print 'File name: '
    puts e_filename = 'file.csv'
    [e_url, e_filename]
  end
end

# запись в файл параметров:
# create_yaml parameters_for_yaml

parameters = YAML.load_file('parameters.yml')
CSV.open(parameters[1], 'wb') do |csv|
  csv << ['Product name', 'Price', 'Picture']
end
Parser.new(parameters[0]).parse_to(parameters[1])
puts 'Finished, check the file'

# time = Time.now.to_i
# time1 = Time.now.to_i
# puts "#{time1 - time} sec"
