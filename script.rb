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

#html = URI.open(url)
#doc = Nokogiri::HTML(html)

html = Curl.get(url) do |curl|
  curl.ssl_verify_peer = false
  curl.ssl_verify_host = 0
end
doc = Nokogiri::HTML(html.body_str)

print 'Found product count: '
puts product_count = doc.xpath('//*[@id="nb_item_bottom"]/@value').to_s.strip.to_i
print 'Page count (25 products): '
puts page_count = (product_count / 25.0).ceil
CSV.open(filename, 'wb') do |csv_line|
  csv_line << ['Product name', 'Product price', 'Product image']
  puts 'Opened csv file, going to run loop'
  (0..page_count).each do |i|
    if i > 1.5
      puts 'It is more than 1 page here. Im going to add ?p=i at the end of the link'
      link = url + "?p=#{i}"
      html = Curl.get(link) do |curl|
        curl.ssl_verify_peer = false
        curl.ssl_verify_host = 0
      end
      doc = Nokogiri::HTML(html.body_str)
    end
    products = doc.xpath('//*[@id="product_list"]')
    products.collect do |product|
      (0..25).each do |i|
        #productdoc=product.at_xpath("li[#{i}]/div[1]/div[2]/div[1]/a/@href").to_s.strip
        #puts productdoc
        #html1 = URI.open(productdoc)
        #doc1 = Nokogiri::HTML(html1)
        #title = doc1.at_xpath('/html/body/div[1]/div[1]/div[5]/div[1]/div/div/div/div[2]/div[2]/div[1]/div/h1/text()').to_s.strip

        title = product.at_xpath("li[#{i}]/div[1]/div[2]/div[3]/div[1]/div/a/@title").to_s.strip
        price = product.at_xpath("li[#{i}]/div[1]/div[2]/div[3]/div[2]/div[1]/span/text()").to_s.strip
        cents= product.at_xpath("li[#{i}]/div[1]/div[2]/div[3]/div[2]/div[1]/span/span/text()").to_s.strip
        pic = product.at_xpath("li[#{i}]/div[1]/div[2]/div[2]/a/img/@src").to_s.strip
        #print "#{product.at_xpath(xpath).to_s.strip} "
        line = [title.to_s, price.to_s + cents.to_s, pic]
        next if title.to_s.empty?
        csv_line << line
      end
    end
  end
end

puts 'File Write is successful'

