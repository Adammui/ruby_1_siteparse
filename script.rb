# frozen_string_literal: true

require 'nokogiri'
require 'curb'
require 'csv'
require 'open-uri'

def get_html(url)
  html_file = URI.open(url) # 69 sec
  Nokogiri::HTML(html_file)
  # html_file = Curl.get(url) do |curl| # 115 sec
  #  curl.ssl_verify_peer = false
  #  curl.ssl_verify_host = 0
  # end
  # Nokogiri::HTML(html_file.body_str)
end

def xp_format(html, xpath_str)
  html.xpath(xpath_str).to_s.strip
end

def get_product_variations(page_html, product_num)
  product_url = xp_format(page_html, "//*[@id='product_list']/li[#{product_num}]/div[1]/div[2]/div[3]/div[1]/div/a/@href")
  product_html = get_html(product_url)
  option = 1
  pr_line = []
  begin
    product_option = xp_format(product_html, "//*[@class='attribute_list']/ul/li[#{option}]/label/span[1]/text()")
    product_price = xp_format(product_html, "//*[@class='attribute_list']/ul/li[#{option}]//span[2]/text()")
    product_name = xp_format(product_html, "//h1[@class='product_main_name']/text()")
    product_img = xp_format(product_html, "//*[@id='bigpic']/@src")
    pr_line.push("#{product_name}-#{product_option} #{product_price} #{product_img}")
    option += 1
    product_option = xp_format(product_html, "//*[@class='attribute_list']/ul/li[#{option}]/label/span[1]/text()")
  end until product_option.to_s.empty?
  pr_line
end

def write_to_file(filename, buffer)
  CSV.open(filename, 'w') do |csv_line|
    # csv_line << ['Product name', 'Product price', 'Product image']
    buffer.each do |x|
      csv_line << x
    end
  end
end

def change_page_html(url, html, page_num)
  page_html = html
  if page_num > 1
    link = url + "?p=#{page_num}"
    page_html = get_html(link) # 25
  end
  page_html
end

def parse(url, filename)
  html = get_html(url)
  print 'Found product count: '
  puts product_count = xp_format(html, '//*[@id="nb_item_bottom"]/@value').to_i
  print 'Page count (25 products each): '
  puts page_count = (product_count / 25.0).ceil
  puts 'It is more than 1 page here. Im going to add ?p=i at the end of the link' if page_count > 1
  buffer = []
  (0..page_count).each do |page_num|
    page_html = change_page_html(url, html, page_num)
    (1..25).each do |product_num|
      break if product_count < 1

      product_vars = get_product_variations(page_html, product_num)
      buffer.push(product_vars)
      puts "written #{product_num} line to buffer"
      product_count -= 1
    end
  end
  write_to_file(filename, buffer)
end

print 'Page address:'
puts e_url = gets.chomp # https://www.petsonic.com/pienso-ownat-perros/
print 'Put file name:'
e_filename = gets.chomp

time = Time.now.to_i
parse(e_url, e_filename)
time1 = Time.now.to_i
puts "#{time1 - time} sec"
puts 'Finished, check the file'
