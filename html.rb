require 'nokogiri'
require 'curb'

module HTML
  def get_html(url)
    html_file = Curl.get(url) do |curl|
      curl.ssl_verify_peer = false
      curl.ssl_verify_host = 0
    end
    Nokogiri::HTML(html_file.body_str)
  end

  def get_next_page_html(url, page_num)
    get_html(url + "?p=#{page_num}") if page_num > 1
  end
end