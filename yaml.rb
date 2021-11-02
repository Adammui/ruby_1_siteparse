require 'yaml'
# todo delet this
module YAML
  def create_yaml(array)
    yaml_obj = YAML.dump(array)
    File.open('parameters.yml', 'w+') do |f|
      f.write(yaml_obj)
    end
  end

  def get_parameters_for_yaml
    print 'Category link: '
    puts  e_url = 'https://www.petsonic.com/carnilove/' # "https://www.petsonic.com/pienso-ownat-perros/"
    print 'File name: '
    puts  e_filename = 'file_threads.csv'
    [e_url, e_filename]
  end
end

def new_yaml
  include YAML
  create_yaml get_parameters_for_yaml
end
# notes
# accessor in product in constructor add ves  edit write to file
# parser  constructor parse to edit
# отдельный модуль по работе с сайтом с тредсами с получением страниц
# продукт с параметрами и аккс и метод сохр в файл
# неск модулей
# вынести тредс в отдельный метод