require 'sinatra/base'
require 'pg'
require 'yaml'
require 'sequel'
require 'active_record'


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
    db.exec("SELECT CURRENT_TIMESTAMP") do |result|
      result.each do |row|
        @pre = row.inspect
      end
    end
    erb :pre
  end

  get "/sequel" do
    db = Sequel.connect(ENV["DATABASE_URL"])
    db["SELECT CURRENT_TIMESTAMP"].each do |row|
      @pre = row.inspect
    end
    erb :pre
  end

  get "/activerecord" do
    ActiveRecord::Base.establish_connection(ENV["DATABASE_URL"])
    result = ActiveRecord::Base.connection.execute("SELECT CURRENT_TIMESTAMP")
    @pre = result[0].inspect
    erb :pre
  end
end
