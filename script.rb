# frozen_string_literal: true

require 'nokogiri'
require 'curb'
require 'csv'

def get_html(url)
  html_file = Curl.get(url) do |curl|
    curl.ssl_verify_peer = false
    curl.ssl_verify_host = 0
  end
  Nokogiri::HTML(html_file.body_str)
end

def get_next_page_html(url, html, page_num)
  page_html = html
  if page_num > 1
    link = url + "?p=#{page_num}"
    page_html = get_html(link) # 25
  end
  page_html
end

def write_to_file(filename, buffer)
  CSV.open(filename, 'a+') do |csv|
    csv << buffer
  end
end

def count_pages(category_html) #todo edit that
  print 'Products in category: '
  puts products_count = category_html.xpath("//input[@id='nb_item_bottom']/@value").to_s
  (products_count.to_i / 25.0).ceil
end

def get_product_variations(product_html) #todo endit the method
  product_variations = []
  product_name = product_html.xpath("//h1[@class='product_main_name']/text()")
  product_img = product_html.xpath("//img[@id='bigpic']/@src")

  product_html.xpath("//ul[@class='attribute_radio_list pundaline-variations']/li/label").each do |option|
    product_option = option.at_xpath("span[@class='radio_label']/text()")
    product_price = option.at_xpath('span[@class="price_comb"]/text()')
    variation = ["#{product_name}- #{product_option}", product_price, product_img]
    product_variations.push(variation)
  end
  product_variations
end

def parse(url, filename)
  category_html = get_html(url)
  page_count = count_pages(category_html)
  puts "Pages: #{page_count}"
  (1..page_count).each do |page_num|
    page_html = get_next_page_html(url, category_html, page_num)
    parse_products_from_page(filename, page_html)
    puts "#{page_num} page of products written "
  end
end

def parse_products_from_page(fname, page_html)
  page_html.xpath("//div[@class='pro_first_box ']//@href").each do |product_url|
    product_html = get_html(product_url)
    variations = get_product_variations(product_html)
    variations.each do |variation|
      write_to_file(fname, variation)
      puts "#{product_url} written"
    end
  end
end

time = Time.now.to_i

print 'Put category link:'
puts e_url = 'https://www.petsonic.com/farmacia-para-gatos/' #"https://www.petsonic.com/pienso-ownat-perros/"
print 'Put file name:'
puts e_filename = 'file.csv'
CSV.open(e_filename, 'wb')

parse(e_url, e_filename)
puts 'Finished, check the file'

time1 = Time.now.to_i
puts "#{time1 - time} sec"