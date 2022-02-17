# Getting Started

*Requirements*
1. When the user visits the path "/", the application should display the text "Getting started."

*Implementation*
1. Set up the project directory, Gemfile, and program file (cms.rb) requirements.
2. Run bundler
3. Write out the route with the required string in it to display the text.

# Adding an Index Page

*Requirements*
1. When a user visits the home page, they should see a list of the documents in the CMS: `history.txt`, `changes.txt`, and `about.txt`.

*Implementation*
1. The files above should be created in a new directory contained within the project directory. We will call this directory `data`
2. The files in the directory `contents` should be iterated through, and their names displayed to the page in the route '/'.
3. Use an ERB template to render the list of documents. Specifically, a layout should be made that yields to `index.erb`

# Viewing Text Files

*Requirements*
1. When a user visits the index page, they are presented with a list of links, one for each document in teh CMS.
2. When a user clicks on a document link in the index, they should be taken to a page that displays the content of the file whose name was clicked.
3. When a user visits the path '/history.txt', they will be presented with the content of the document 'history.txt'.
4. The browser should render a text file as a plain text file.

*Implementation*
1. A route, '/:file_name' should be created.
2. In said route, the file, :file_name, should be pulled up, read, and saved to a variable.
3. Update 'index.rb' to make every file name a link to their corresponding file.
4. Set an appropriate value for the Content-Type header to tell browsers to display the response as plain text. That is, send back an array '[200, {'Content-Type' => 'text/plain'}, file_contents]'

# Adding Tests

*Requirements*
1. Write tests for the routes that the application already supports. Run them and you should see 2 tests, 12 assertions.

*Implementation*
Things to test:
1. Response status for each link, including all variations of '/file_name'
2. Content types
3. Bodies are in line with what they should be.

# Handling Requests for Nonexistent Documents

*Requirements*
1. When a user attempts to view a document that does not exist, they should be redirected to the index page and shown the message: '$DOCUMENT does not exist.'
2. When the user reloads the index page after seeing an error message, the message should go away.

*Implementation*
0. Enable sessions and determine if the file exists when it is called.
1. Create a conditional within '/:file_name' route for success and failure. In the failure route, set `session[:error]` to the desired text and then redirect to '/'
2. In the layout template, add a conditional above the main content that displays, then deletes the error message, if one is present.
