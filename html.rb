require 'nokogiri'
require 'curb'

module HTML
  def self.get_html(url)
    html_file = Curl.get(url) do |curl|
      curl.ssl_verify_peer = false
      curl.ssl_verify_host = 0
    end
    Nokogiri::HTML(html_file.body_str)
  end
end
