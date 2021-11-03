require_relative 'product'
require './html'

class Parser
  include HTML
  def initialize
    @params = YAML.load_file('parameters.yml')
    @html = get_html(@params['link'])
  end

  def parse_pages
    (1..get_pages_count).each do |page_num|
      go_to_next_page(page_num)
      download_product_pages.each { |product_html| write_product(product_html) }
    end
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

  def download_product_pages
    pages = []
    threads = []
    get_product_urls.each do |product_url|
      threads << Thread.new do
        pages << get_html(product_url)
      end
    end
    threads.map(&:join)
    pages
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
    products_on_page = @params['products_on_page'].to_f
    print 'Pages: '
    puts pages = (products_count.to_i / products_on_page).ceil
    pages
  end
end
