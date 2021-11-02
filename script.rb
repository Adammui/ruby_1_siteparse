require 'csv'
require_relative 'yaml'
require_relative 'parser'

# запись в файл параметров:
# new_yaml

# счетчик времени работы скрипта:
time = Time.now.to_i

parameters = YAML.load_file('parameters.yml')
CSV.open(parameters[1], 'wb') do |csv|
  csv << ['Product name', 'Price', 'Picture']
end
Parser.new(parameters[0]).parse_to(parameters[1])
puts 'Finished, check the file'

time1 = Time.now.to_i
puts "#{time1 - time} sec"

# 40s before threads
# 10s after using threads
