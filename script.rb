require 'csv'
require_relative 'yaml'
require_relative 'parser'

# запись в файл параметров:
# new_yaml

# счетчик времени работы скрипта:
time = Time.now.to_i

params = YAML.load_file('parameters.yml')
puts params.inspect
puts params['link']
puts params['xpath']['product_title']
CSV.open(params['filename'], 'wb') do |csv|
  csv << ['Product name', 'Price', 'Picture']
end

Parser.parse_pages
puts 'Finished, check the file'

time1 = Time.now.to_i
puts "#{time1 - time} sec"

# 40s before threads
# 10s after using threads
