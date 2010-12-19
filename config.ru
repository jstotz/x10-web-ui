require 'rubygems'
require 'sinatra/base'
require 'yaml'
require 'sha1'

class X10Handler < Sinatra::Base
  helpers do
    def config
      @config ||= YAML.load_file('config.yml')
    end

    def validate_password
      unless config['password'] && params[:p] == SHA1.hexdigest(config['password'])
        halt 400, 'Invalid password'
      end
    end
    
    def validate_command
      unless params[:c] && params[:c] =~ /^[+|-][a-zA-Z]\d{1,3}$/
        halt 400, 'Invalid command'
      end
    end
  end
  
  post '/' do
    validate_password
    validate_command
    system %Q{echo "#{params[:c]}" | python ./lib/pycm19a/pycm19a.py}
    unless $? == 0
      halt 400, 'Failed to send command'
    end
  end
  
  get '/' do
    validate_password
    erb :index
  end
end

run X10Handler