require_relative 'html'
require_relative 'product'

class Parser
  include HTML
  def initialize(url)
    @url = url
    @html = get_html(url)
    @pages_count = get_pages_count
  end

  def parse_to(filename)
    threads = []
    (1..@pages_count).each do |page_num|
      @html = get_next_page_html(@url, page_num) if page_num > 1
      @html.xpath("//div[@class='pro_first_box ']//@href").each do |product_url|
        threads << Thread.new do
          Product.new(product_url).get_product_variations.write_variations_to_file(filename)
        end
      end
      threads.map(&:join)
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