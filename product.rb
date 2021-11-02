require_relative 'html'
require 'csv'

class Product
  include HTML_pr
  attr_accessor :title, :price, :img

  def initialize
    @params = YAML.load_file('parameters.yml')
  end
  def write_to_file
    CSV.open(@params['filename'], 'a+') do |csv|
      csv << [title, price, img]
    end
    puts "Written | #{@title}"
  end
end