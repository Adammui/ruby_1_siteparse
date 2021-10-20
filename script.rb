# frozen_string_literal: true

require 'open-uri'
require 'nokogiri'
require 'curb'
require 'csv'


puts 'Page address:'
# gets
puts url = 'https://www.petsonic.com/farmacia-para-gatos/'
puts 'Put file name:'
#filename = gets

#html = URI.open(url)
html = Curl.get(url)
doc = Nokogiri::HTML(html.body_str)
#html = Curl.get(url)
#puts html.body_str

doc = Nokogiri::HTML(html)

rows = doc.xpath('//*[@id="st_advanced_ma_9046"]')
details = rows.collect do |row|
  detail = {}
  [
    [:title, '@title']
  ].each do |name, xpath|
    puts row.at_xpath(xpath).to_s.strip
  end
  detail
end
