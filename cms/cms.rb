# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/content_for'
require 'tilt/erubis'
require 'redcarpet'
require 'pry'
require 'bcrypt'
require 'yaml'

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

# Displays index of files in data folder.
get '/' do
  @files = Dir.children data_path
  erb :index, layout: :layout
end

# Page to create a new file.
get '/new' do
  verify_signin_status

  erb :new_file, layout: :layout
end

# Creates a new document
def create_document(name, content = '')
  File.open(File.join(data_path, name), 'w') do |file|
    file.write(content)
  end
end

# Verifies that the filename has a valid extention
def verify_name(filename)
  if filename =~ /\.[a-zA-Z]+$/
    filename
  else
    "#{filename}.txt"
  end
end

# Creates a new document
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

# Renders a markdown file as a markup file.
def render_markdown_file(path)
  markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML)
  markdown.render(File.read(path))
end

# Loads a file's contents onto the browser
def load_file_content(path)
  case File.extname(path)
  when '.txt'
    headers['Content-Type'] = 'text/plain'
    File.read(path)
  when '.md'
    erb render_markdown_file(path)
  end
end

# Page for reading the contents of a file
get '/:filename/read_file' do |filename|
  path = File.join(data_path, filename)

  if File.file? path
    load_file_content path
  else
    session[:message] = "#{filename} does not exist."
    redirect '/'
  end
end

# Page to edit the contents of a file
get '/:filename/edit_file' do |filename|
  verify_signin_status

  path = File.join(data_path, filename)
  @filename = filename
  @contents = File.read(path)

  erb :edit_file, layout: :layout
end

# Edits the contents of a file
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

# Deletes a file
post '/:filename/delete' do |filename|
  verify_signin_status

  file_path = File.join(data_path, filename)
  File.delete file_path

  session[:message] = "#{filename} has been deleted"
  redirect '/'
end

# Sign in page
get '/users/signin' do
  erb :signin, layout: :layout
end

def load_user_credentials
  credentials_path = if ENV['RACK_ENV'] == 'test'
    File.expand_path('test/users.yml', __dir__)
  else
    File.expand_path('users.yml', __dir__)
  end
  YAML.load_file(credentials_path)
end

# Submits and validates user sign in credentials
post '/users/signin' do
  credentials = load_user_credentials
  username = params[:username]

  if credentials[username] == params[:password]
    session[:username] = username
    session[:message] = 'Welcome!'
    redirect '/'
  else
    status 422
    session[:message] = 'Invalid credentials'
    erb :signin, layout: :layout
  end
end

# Signs out a user
post '/users/signout' do
  session[:username] = nil
  session[:message] = 'You have been signed out'
  redirect '/'
end
