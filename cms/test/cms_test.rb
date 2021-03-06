# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'minitest/reporters'
Minitest::Reporters.use!
require 'rack/test'
require 'fileutils'

require_relative '../cms'

class CMSTest < Minitest::Test
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def setup
    FileUtils.mkdir_p(find_path_to('data'))
  end

  def teardown
    FileUtils.rm_rf(find_path_to('data'))
  end

  def create_document(name, content = '')
    File.open(File.join(find_path_to('data'), name), 'w') do |file|
      file.write(content)
    end
  end

  def admin_session
    { 'rack.session' => { username: 'admin' } }
  end

  def session
    last_request.env['rack.session']
  end

  def test_index
    create_document 'about.md'
    create_document 'changes.txt'

    get '/'

    assert_equal 200, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    assert_includes last_response.body, 'about.md'
    assert_includes last_response.body, 'changes.txt'
  end

  def test_viewing_text_document
    create_document 'file.txt', 'working on it'

    get '/file.txt/read_file'

    assert_equal 200, last_response.status
    assert_equal 'text/plain', last_response['Content-Type']
    assert_includes last_response.body, 'working on it'
  end

  def test_viewing_markdown_document
    create_document 'file.md', '# Heading'

    get '/file.md/read_file'

    assert_equal 200, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    assert_includes last_response.body, '<h1>Heading</h1>'
  end

  def test_file_not_found_message
    get '/file.txt/read_file'

    assert_equal 302, last_response.status
    assert_equal 'file.txt does not exist.', session[:message]
  end

  def test_editing_document
    create_document 'file.txt'
    get '/file.txt/edit_file', {}, admin_session

    assert_equal 200, last_response.status
    assert_includes last_response.body, '</textarea>'
    assert_includes last_response.body, '<button type="submit"'
  end

  def test_editing_document_signed_out
    create_document 'changes.txt'

    get '/changes.txt/edit_file'

    assert_equal 302, last_response.status
    assert_equal 'You must be signed in to do that.', session[:message]
  end

  def test_updating_document
    post '/file.txt/edit_file', { edit: 'new content' }, admin_session

    assert_equal 302, last_response.status
    assert_includes 'file.txt has been updated.', session[:message]

    get '/file.txt/read_file'
    assert_equal 200, last_response.status
    assert_includes last_response.body, 'new content'
  end

  def test_updating_document_signed_out
    post '/changes.txt/edit_file', { edit: 'new content' }

    assert_equal 302, last_response.status
    assert_equal 'You must be signed in to do that.', session[:message]
  end

  def test_view_new_document_form
    get '/new', {}, admin_session

    assert_equal 200, last_response.status
    assert_includes last_response.body, '<input'
    assert_includes last_response.body, '<button type="submit"'
  end

  def test_view_new_document_form_signed_out
    get '/new'

    assert_equal 302, last_response.status
    assert_equal 'You must be signed in to do that.', session[:message]
  end

  def test_create_new_document
    post '/create', { title: 'test.txt' }, admin_session

    assert_equal 302, last_response.status
    assert_includes session[:message], 'test.txt has been created.'

    get '/'
    assert_includes last_response.body, 'test.txt'
  end

  def test_create_new_document_signed_out
    post '/create', { title: 'test.txt' }

    assert_equal 302, last_response.status
    assert_equal 'You must be signed in to do that.', session[:message]
  end

  def test_create_new_document_without_filename
    post '/create', { title: '' }, admin_session
    assert_equal 422, last_response.status
    assert_includes last_response.body, 'A name is required'
  end

  def test_deleting_document
    create_document 'test.txt'

    post '/test.txt/delete', {}, admin_session
    assert_equal 302, last_response.status
    assert_includes 'test.txt has been deleted.', session[:message]

    get '/'
    refute_includes last_response.body, 'href="/test.txt"'
  end

  def test_deleting_document_signed_out
    create_document('test.txt')

    post '/test.txt/delete'
    assert_equal 302, last_response.status
    assert_equal 'You must be signed in to do that.', session[:message]
  end

  def test_signin_form
    get '/users/signin'

    assert_equal 200, last_response.status
    assert_includes last_response.body, '<input'
    assert_includes last_response.body, '<button type="submit"'
  end

  def test_signin
    post '/users/signin', username: 'admin', password: 'secret'
    assert_equal 302, last_response.status
    assert_includes 'Welcome!', session[:message]
    assert_equal 'admin', session[:username]

    get last_response['Location']
    assert_includes last_response.body, 'Signed in as admin'
  end

  def test_signin_with_bad_credentials
    post '/users/signin', username: 'guest', password: 'shhhh'
    assert_equal 422, last_response.status
    assert_nil session[:username]
    assert_includes last_response.body, 'Invalid credentials'
  end

  def test_signout
    get '/', {}, { 'rack.session' => { username: 'admin' } }
    assert_includes last_response.body, 'Signed in as admin'

    post '/users/signout'
    assert_equal session[:message], 'You have been signed out'

    get last_response['Location']
    assert_nil session[:username]
    assert_includes last_response.body, 'Sign In'
  end
end
