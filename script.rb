# frozen_string_literal: true

require 'nokogiri'
require 'curb'
require 'csv'
require 'open-uri'

def xp_format(html, xpath_str)
  html.xpath(xpath_str).to_s.strip
end

def get_html(url)
  #html_file = URI.open(url) # another variant
  #Nokogiri::HTML(html_file)
  html_file = Curl.get(url) do |curl|
   curl.ssl_verify_peer = false
   curl.ssl_verify_host = 0
  end
   Nokogiri::HTML(html_file.body_str)
end

def change_page_html(url, html, page_num)
  page_html = html
  if page_num > 1
    link = url + "?p=#{page_num}"
    page_html = get_html(link) # 25
  end
  page_html
end

def get_product_html(product_num, page_html)
  product_url = xp_format(page_html, "//*[@id='product_list']/li[#{product_num}]/div[1]/div[2]/div[3]/div[1]/div/a/@href")
  return get_html(product_url)
end

def get_product_to_file(fname, product_html)
  option = 1
  begin
    product_option = xp_format(product_html, "//*[@class='attribute_list']/ul/li[#{option}]/label/span[1]/text()")
    product_price = xp_format(product_html, "//*[@class='attribute_list']/ul/li[#{option}]//span[2]/text()")
    product_name = xp_format(product_html, "//h1[@class='product_main_name']/text()")
    product_img = xp_format(product_html, "//*[@id='bigpic']/@src")
    pr_line = ["#{product_name}- #{product_option}", product_price, product_img]
    write_to_file(fname, pr_line)
    option += 1
    product_option = xp_format(product_html, "//*[@class='attribute_list']/ul/li[#{option}]/label/span[1]/text()")
  end until product_option.to_s.empty?
end

def write_to_file(filename, buffer)
  CSV.open(filename, "a+") do |csv|
    csv << buffer
  end
end

def parse(url, filename)
  time = Time.now.to_i
  CSV.open(filename, "wb")
  html = get_html(url)
  print 'Product links count: '
  puts product_count = xp_format(html, '//*[@id="nb_item_bottom"]/@value').to_i
  print 'Page count (25 products each): '
  puts page_count = (product_count / 25.0).ceil
  (0..page_count).each do |page_num|
    page_html = change_page_html(url, html, page_num)
    (1..25).each do |product_num|
      break if product_count < 1

      pr_html = get_product_html(product_num, page_html)
      get_product_to_file(filename, pr_html)
      puts "written #{product_num} product and its variations"
      product_count -= 1
    end
  end
  time1 = Time.now.to_i
  puts "#{time1 - time} sec"
end

print 'Page address:'
puts e_url = gets.chomp # https://www.petsonic.com/pienso-ownat-perros/
print 'Put file name:'
e_filename = gets.chomp

parse(e_url, e_filename)
puts 'Finished, check the file'
