require 'csv'
require './parser'

# счетчик времени работы скрипта:
time = Time.now.to_i

params = YAML.load_file('parameters.yml')
CSV.open(params['filename'], 'wb') do |csv|
  csv << ['Product name', 'Price', 'Picture']
end

Parser.new.parse_pages
puts 'Finished, check the file'

time1 = Time.now.to_i
puts "#{time1 - time} sec"

# 40s before threads
# 10s after using threads
