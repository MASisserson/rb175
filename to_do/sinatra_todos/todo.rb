# frozen_string_literal: false

require 'sinatra'
require 'sinatra/reloader'
require 'tilt/erubis'
require 'sinatra/content_for'

require 'pry'

configure do
  enable :sessions
  set :sessions_secret, 'secret'
end

before do
  session[:lists] ||= []
  @lists = session[:lists]
end

not_found do
  redirect '/lists'
end

get '/' do
  redirect '/lists'
end

# View list of lists
get '/lists' do
  erb :lists, layout: :layout
end

# Render the new list form
get '/lists/new' do
  erb :new_list, layout: :layout
end

# Return an error message if the name is invalid. Return nil if name is valid.
def error_for_list_name(name)
  if !(1..100).cover? name.size
    'List name must be between 1 and 100 characters.'
  elsif session[:lists].any? { |list| list[:name] == name }
    'List name must be unique.'
  end
end

# Create a new list
post '/lists' do
  list_name = params[:list_name].strip

  if (error = error_for_list_name(list_name))
    session[:error] = error
    erb :new_list, layout: :layout
  else
    session[:lists] << { name: list_name, todos: [] }
    session[:success] = 'The list has been created.'
    redirect '/lists'
  end
end

# Display list items
get '/lists/:id' do
  @id = params[:id].to_i
  @list = session[:lists][@id]
  erb :id, layout: :layout
end

# Render list editing form
get '/lists/:id/edit' do
  @id = params[:id].to_i
  @list = session[:lists][@id]
  erb :edit_list, layout: :layout
end

# Edit list
post '/lists/:id' do
  list_name = params[:list_name].strip
  @id = params[:id].to_i
  @list = session[:lists][@id]

  if (error = error_for_list_name(list_name))
    session[:error] = error
    erb :edit_list, layout: :layout
  else
    @list[:name] = list_name
    session[:success] = 'The list has been updated.'
    redirect "/lists/#{@id}"
  end
end

# Delete a todo list
post '/lists/:id/delete' do |id|
  name = @lists[id.to_i][:name]
  @lists.delete_at id.to_i
  session[:success] = "The list \"#{name}\" has been deleted."
  redirect '/lists'
end

# Add a new todo to a list
post '/lists/:list_id/todos' do |list_id|
  todo = params[:todo].strip
  @list = @lists[list_id.to_i]

  error = error_for_todo
  if error
    session[:error] = error
    @id = list_id.to_i
    erb :id, layout: :layout
  else
    @list[:todos] << { name: todo, completed: false }
    session[:success] = params[:todo] + ' was added to the list!'
    redirect "/lists/#{list_id}"
  end
end
