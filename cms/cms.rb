# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/content_for'
require 'tilt/erubis'
require 'redcarpet'
require 'pry'

configure do
  enable :sessions
  set :sessions_secret, 'secret'
  set :erb, escape_html: true
end

before do
  @title = 'Content Manager'
end

def data_path
  if ENV['RACK_ENV'] == 'test'
    File.expand_path('test/data', __dir__)
  else
    File.expand_path('data', __dir__)
  end
end

def verify_signin_status
  return if session[:username]

  session[:message] = 'You must be signed in to do that.'
  redirect '/'
end

get '/' do
  @files = Dir.children data_path
  erb :index, layout: :layout
end

get '/new' do
  verify_signin_status

  erb :new_file, layout: :layout
end

def create_document(name, content = '')
  File.open(File.join(data_path, name), 'w') do |file|
    file.write(content)
  end
end

def verify_name(filename)
  if filename =~ /\.[a-zA-Z]+$/
    filename
  else
    "#{filename}.txt"
  end
end

post '/create' do
  verify_signin_status

  if params[:title].strip.empty?
    session[:message] = 'A name is required.'
    status 422
    erb :new_file, layout: :layout
  else
    filename = verify_name(params[:title])
    create_document filename
    session[:message] = "#{filename} has been created."
    redirect '/'
  end
end

def render_markdown_file(path)
  markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML)
  markdown.render(File.read(path))
end

def load_file_content(path)
  case File.extname(path)
  when '.txt'
    headers['Content-Type'] = 'text/plain'
    File.read(path)
  when '.md'
    erb render_markdown_file(path)
  end
end

get '/:filename/read_file' do |filename|
  path = File.join(data_path, filename)

  if File.file? path
    load_file_content path
  else
    session[:message] = "#{filename} does not exist."
    redirect '/'
  end
end

get '/:filename/edit_file' do |filename|
  verify_signin_status

  path = File.join(data_path, filename)
  @filename = filename
  @contents = File.read(path)

  erb :edit_file, layout: :layout
end

post '/:filename/edit_file' do |filename|
  verify_signin_status

  path = File.join(data_path, filename)
  File.open(path, 'w') do |file|
    file.puts params[:edit]
    file.close
  end

  session[:message] = "#{filename} has been updated."
  redirect '/'
end

post '/:filename/delete' do |filename|
  verify_signin_status

  file_path = File.join(data_path, filename)
  File.delete file_path

  session[:message] = "#{filename} has been deleted"
  redirect '/'
end

get '/users/signin' do
  erb :signin, layout: :layout
end

USERS = {
  'admin' => 'secret'
}.freeze

post '/users/signin' do
  USERS.each do |user, password|
    next unless (user == params[:username]) &&
                (password == params[:password])

    session[:username] = params[:username]
    session[:message] = 'Welcome!'
    redirect '/'
  end

  status 422
  session[:message] = 'Invalid credentials'
  @username = params[:username]
  erb :signin, layout: :layout
end

post '/users/signout' do
  session[:username] = nil
  session[:message] = 'You have been signed out'
  redirect '/'
end
