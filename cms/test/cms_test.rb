ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'minitest/reporters'
Minitest::Reporters.use!
require 'rack/test'

require 'securerandom'

require_relative '../cms.rb'

class CMSTest < Minitest::Test
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def setup
    @root = File.expand_path("../..", __FILE__)

    @file_names = Dir.each_child("#{@root}/data")
  end

  def test_index
    get '/'
    assert_equal 200, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    @file_names.each do |file_name|
      assert_includes last_response.body, file_name
    end
  end

  def test_files
    @file_names.each do |file_name|
      file = File.new("#{@root}/data/#{file_name}")

      get "/#{file_name}"
      assert_equal 200, last_response.status
      assert_equal 'text/plain', last_response['Content-Type']
      assert_equal File.read(file), last_response.body
    end
  end

  def test_file_not_found_message
    random_name = String.new
    loop do
      random_name = "#{SecureRandom.alphanumeric}.ext"
      break if !@file_names.include? random_name
    end

    get "/#{random_name}"

    assert_equal 302, last_response.status

    get last_response['Location']
    
    assert_equal 200, last_response.status
    assert_includes last_response.body, "#{random_name} does not exist."

    get '/'
    refute_includes last_response.body, "#{random_name} does not exist."
  end
end
