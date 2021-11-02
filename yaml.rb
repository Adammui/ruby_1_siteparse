require 'yaml'

module YAML
  def create_yaml(array)
    yaml_obj = YAML.dump(array)
    File.open('parameters.yml', 'w+') do |f|
      f.write(yaml_obj)
    end
  end

  def get_parameters_for_yaml
    print 'Category link: '
    puts  e_url = gets # 'https://www.petsonic.com/carnilove/' # "https://www.petsonic.com/pienso-ownat-perros/"
    print 'File name: '
    puts  e_filename = gets # 'file.csv'
    [e_url, e_filename]
  end
end

def new_yaml
  include YAML
  create_yaml get_parameters_for_yaml
end
