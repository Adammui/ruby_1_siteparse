require_relative 'product'
require_relative 'html.rb'

module Parser
  include HTML_pr
  @params = YAML.load_file('parameters.yml')
  @html = HTML_pr.get_html(@params['link'])
  @pages_count = get_pages_count

  def parse_pages
    (1..@pages_count).each do |page_num|
      go_to_next_page(page_num)
      download_product_pages.each { |product_html| write_product(product_html) }
    end
  end

  def download_product_pages
    pages, threads = []
    get_product_urls.each do |product_url|
      threads << Thread.new do
        pages << get_html(product_url)
      end
    end
    threads.map(&:join)
    pages
  end

  def write_product(product_html)
    product_html.xpath(@params['xpath']['product_variations']).each do |option|
      pr = Product.new
      pr.title = "#{product_html.xpath(@params['xpath']['product_title'])} -#{option.at_xpath(@params['xpath']['product_option'])}"
      pr.price = option.at_xpath(@params['xpath']['product_price'])
      pr.img = product_html.xpath(@params['xpath']['product_img'])
      pr.write_to_file
    end
  end

  def get_product_urls
    @html.xpath(@params['xpath']['product_urls'])
  end

  def go_to_next_page(page_num)
    puts "Going to #{page_num} page of products"
    @html = get_html(@params['link'] + "?p=#{page_num}") if page_num > 1
  end

  def get_pages_count
    products_count = @html.xpath(@params['xpath']['count_products']).to_s
    print 'Pages: '
    puts pages = (products_count.to_i / 25.0).ceil
    pages
  end
end
