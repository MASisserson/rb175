require "sinatra"
require "sinatra/reloader"
require_relative "methods.rb"

get "/" do
  @files = Methods.directory_files('./dir/').sort
  @files.reverse! if params[:sort] == "desc"
  erb :home
end

# get "/" do
#   @files = Methods.directory_files('./dir/')

#   erb :home
# end

# get "/ascending" do
#   @files = Methods.directory_files('./dir/')

#   erb :ascending
# end

# get "/descending" do
#   @files = Methods.directory_files('./dir/')

#   erb :descending
# end