require 'sinatra/base'
require 'pg'
require 'yaml'

class Failover < Sinatra::Base
  get "/" do
    "Hello world"
  end

  get "/env" do
    @pre = ENV.to_hash.to_yaml
    erb :pre
  end
  
  get "/time" do
    db = PG.connect(ENV["DATABASE_URL"] + "?connect_timeout=2")
    @pre = "Unknown"
    db.exec("SELECT CURRENT_TIMESTAMP") do |result|
      result.each do |row|
        @pre = row.inspect
      end
    end
    erb :pre
  end
end
