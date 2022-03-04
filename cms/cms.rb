# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/content_for'
require 'tilt/erubis'
require 'redcarpet'
require 'pry'
require 'bcrypt'
require 'yaml'

require_relative 'user_obj'

configure do
  enable :sessions
  set :sessions_secret, 'secret'
  set :erb, escape_html: true
end

before do
  @title = 'Content Manager'
end

def find_path_to(dir)
  if ENV['RACK_ENV'] == 'test'
    File.expand_path("test/#{dir}", __dir__)
  else
    File.expand_path(dir, __dir__)
  end
end

# def data_path
#   if ENV['RACK_ENV'] == 'test'
#     File.expand_path('test/data', __dir__)
#   else
#     File.expand_path('data', __dir__)
#   end
# end

def verify_signin_status
  return if session[:curr_usr]

  session[:message] = 'You must be signed in to do that.'
  redirect '/'
end

# Displays index of files in data folder.
get '/' do
  @files = Dir.children find_path_to('data')
  erb :index, layout: :layout
end

# Page to create a new file.
get '/new' do
  verify_signin_status

  erb :new_file, layout: :layout
end

# Creates a new document
def create_document(name, content = '')
  File.open(File.join(find_path_to('data'), name), 'w') do |file|
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
  path = File.join(find_path_to('data'), filename)

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

  path = File.join(find_path_to('data'), filename)
  @filename = filename
  @contents = File.read(path)

  erb :edit_file, layout: :layout
end

# Edits the contents of a file
post '/:filename/edit_file' do |filename|
  verify_signin_status

  path = File.join(find_path_to('data'), filename)
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

  file_path = File.join(find_path_to('data'), filename)
  File.delete file_path

  session[:message] = "#{filename} has been deleted"
  redirect '/'
end

# Sign in page
get '/users/signin' do
  erb :signin, layout: :layout
end

# Returns an array of user YAML files
def all_users
  users_dir = find_path_to 'users'

  files = Dir.children(users_dir).select do |filename|
    filename.end_with? '.yml'
  end

  files.map do |filename|
    path = File.join(users_dir, filename)
    YAML.load_file(path)
  end
end

# Looks for a user yml file based on given username
def find_user(username)
  all_users.each do |obj|
    return obj if obj.username == username
  end

  false
end

# Validate login credentials
def valid_credentials?(saved_usr, username, saved_pwd, password)
  if saved_usr.username == username
    bcrypt_password = BCrypt::Password.new(saved_pwd)
    bcrypt_password == password
  else
    false
  end
end

# Submits and validates user sign in credentials
post '/users/signin' do
  username = params[:username]
  password = params[:password]
  @user = find_user(username)
  @users = all_users

  if @user != false && valid_credentials?(@user,
                                          username,
                                          @user.password, password)

    session[:message] = 'Welcome!'
    session[:curr_usr] = username
    redirect '/'
  else
    status 422
    session[:message] = 'Invalid credentials'
    erb :signin, layout: :layout
  end
end

# Signs out a user
post '/users/signout' do
  session[:curr_usr] = nil
  session[:message] = 'You have been signed out'
  redirect '/'
end

# Page for user account credential creation.
get '/users/new' do
  erb :new_user, layout: :layout
end

# Checks that the submitted username is valid.
def valid_username?(username)
  users = all_users

  users.each { |obj| return false if obj.username == username }
  true
end

# Checks that the submitted password is valid
def valid_password?(password, password_confirm)
  password == password_confirm
end

# Creates a new user object with the given username and password
def create_user(username, password)
  User.new(username, BCrypt::Password.create(password).split('').join(''))
end

# Creates a user.yml file based on the given User instance.
def create_user_yml(obj)
  path = find_path_to 'users'
  file_name = "#{obj.username}.yml"
  file_path = File.join path, file_name
  File.open(file_path, 'w') { |file| file.write(obj.to_yaml) }
end

# Creates a user account, and automatically logs it in.
post '/users/new' do
  username = params[:username]
  password = params[:password]
  pwd_confirm = params[:confirm]

  if !valid_username?(username)
    session[:message] = 'Username already in use.'
    erb :new_user, layout: :layout
  elsif !valid_password?(password, pwd_confirm)
    session[:message] = 'Passwords do not match.'
    erb :new_user, layout: :layout
  else
    new_user = create_user(username, password)
    create_user_yml(new_user)

    session[:curr_usr] = username
    redirect '/'
  end
end
