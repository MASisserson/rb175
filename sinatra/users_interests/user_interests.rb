require 'tilt/erubis'
require 'sinatra'
require 'sinatra/reloader'
require 'yaml'

before do
  @users = YAML.load(File.read('users.yaml'))
  @usernames = @users.map { |name, info| name.to_s }
  @interest_count = count_interests
end

helpers do
  def count_interests
    interests = Array.new
    @users.each do |name, info|
      info[:interests].each { |interest| interests << interest }
    end
    interests.uniq.count
  end
end

get "/" do
  redirect "/users"
end

not_found do
  redirect "/users"
end

get "/users" do
  @title = "User List"

  erb :users
end

get "/users/:name" do
  @username = params[:name]
  @info = @users[@username.to_sym]
  @title = @username.capitalize
  @usernames.delete(@username)

  erb :specific_user
end
