# frozen_string_literal: true

require 'open-uri'
require 'nokogiri'
require 'curb'
require 'csv'


print 'Page address:'
# gets
puts url = 'https://www.petsonic.com/cicatrizantes-para-gatos/'
print 'Put file name:'
puts filename = gets

html = URI.open(url)
doc = Nokogiri::HTML(html)
#html = Curl.get(url)
#doc = Nokogiri::HTML(html.body_str)

print 'Found product count: '
puts product_count = doc.xpath('//*[@id="nb_item_bottom"]/@value').to_s.strip.to_i
print 'Page count (25 products): '
puts page_count = (product_count / 25.0).ceil
CSV.open(filename, 'wb') do |csv_line|
  csv_line << ['Product name', 'Product price', 'Product image']
  (0..page_count).each do |i|
    if i > 1.5
      link = url + "?p=#{i}"
      html = URI.open(link)
      doc = Nokogiri::HTML(html)
    end
    products = doc.xpath('//*[@id="product_list"]')
    products.collect do |product|
      (0..25).each do |i|
        title = product.at_xpath( "li[#{i}]/div[1]/div[2]/div[3]/div[1]/div/a/@title").to_s.strip
        price = product.at_xpath( "li[#{i}]/div[1]/div[2]/div[3]/div[2]/div[1]/span/text()").to_s.strip
        + "li[#{i}]/div[1]/div[2]/div[3]/div[2]/div[1]/span/span/text()".to_s.strip
        pic = product.at_xpath("li[#{i}]/div[1]/div[2]/div[2]/a/img/@src").to_s.strip
          #print "#{product.at_xpath(xpath).to_s.strip} "
        line = ["#{title} - #{"ves"}", price, pic ]
        csv_line << line
      end
      puts

    end
  end
end

puts 'File Write is successful'

