require 'sinatra/base'
require 'pg'
require 'yaml'
require 'sequel'
require 'active_record'


class Failover < Sinatra::Base
  configure do
    ActiveRecord::Base.establish_connection(ENV["DATABASE_URL"])
  end

  after do
    # Return the connections back to the pool
    # http://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/ConnectionHandler.html#method-i-clear_active_connections-21
    ActiveRecord::Base.clear_active_connections!
  end

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
    STDOUT.puts "Getting connection"
    connection = ActiveRecord::Base.connection
    STDOUT.puts "Got connection"
    result = connection.execute("SELECT CURRENT_TIMESTAMP")
    ActiveRecord::Base.connection_pool.checkin(connection)
    @pre = result[0].inspect
    erb :pre
  end
end
