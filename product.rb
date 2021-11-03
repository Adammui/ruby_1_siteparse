require_relative 'html'
require 'csv'

class Product
  include HTML
  attr_accessor :title, :price, :img

  def write_to_file
    CSV.open(YAML.load_file('parameters.yml')['filename'], 'a+') do |csv|
      csv << [title, price, img]
    end
    puts "Written | #{title}"
  end
end