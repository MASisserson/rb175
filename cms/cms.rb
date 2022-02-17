require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/content_for'
require 'tilt/erubis'

configure do
  enable :sessions
  set :sessions_secret, 'secret'
  set :erb, escape_html: true
end

before do
  @title = 'Content Manager'
end

root = File.expand_path("..", __FILE__)

get '/' do
  @files = Dir.children(root + '/data')
  erb :index, layout: :layout
end

get '/:file_name' do |file_name|
  path = "#{root}/data/#{file_name}"
  if File.file?(path)
    headers['Content-Type'] = 'text/plain'
    File.read(path)
  else
    session[:error] = "#{file_name} does not exist."
    redirect '/'
  end
end
