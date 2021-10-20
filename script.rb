# frozen_string_literal: true

require 'open-uri'
require 'nokogiri'
require 'curb'
require 'csv'


puts 'Page address:'
# gets
puts url = 'https://www.petsonic.com/gatos/'
puts 'Put file name:'
#filename = gets

html = URI.open(url)
doc = Nokogiri::HTML(html)
#html = Curl.get(url)
#doc = Nokogiri::HTML(html.body_str)

products = doc.xpath('//*[@id="product_list"]')
details = products.collect do |product|
  (0..25).each do |i|
    detail = {}
    [
      [:pic, "li[#{i}]/div[1]/div[2]/div[2]/a/img/@src"],
      [:price, "li[#{i}]/div[1]/div[2]/div[3]/div[2]/div[1]/span/text()"],
      [:cents, "li[#{i}]/div[1]/div[2]/div[3]/div[2]/div[1]/span/span/text()"],
      [:title, "li[#{i}]/div[1]/div[2]/div[3]/div[1]/div/a/@title"]
    ].each do |name, xpath|
      puts product.at_xpath(xpath).to_s.strip
    end
    detail
  end
end
