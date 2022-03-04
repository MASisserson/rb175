# Getting Started

**Requirements**
1. When the user visits the path "/", the application should display the text "Getting started."

**Implementation**
1. Set up the project directory, Gemfile, and program file (cms.rb) requirements.
2. Run bundler
3. Write out the route with the required string in it to display the text.

# Adding an Index Page

**Requirements**
1. When a user visits the home page, they should see a list of the documents in the CMS: `history.txt`, `changes.txt`, and `about.txt`.

**Implementation**
1. The files above should be created in a new directory contained within the project directory. We will call this directory `data`
2. The files in the directory `contents` should be iterated through, and their names displayed to the page in the route '/'.
3. Use an ERB template to render the list of documents. Specifically, a layout should be made that yields to `index.erb`

# Viewing Text Files

**Requirements**
1. When a user visits the index page, they are presented with a list of links, one for each document in teh CMS.
2. When a user clicks on a document link in the index, they should be taken to a page that displays the content of the file whose name was clicked.
3. When a user visits the path '/history.txt', they will be presented with the content of the document 'history.txt'.
4. The browser should render a text file as a plain text file.

**Implementation**
1. A route, '/:file_name' should be created.
2. In said route, the file, :file_name, should be pulled up, read, and saved to a variable.
3. Update 'index.rb' to make every file name a link to their corresponding file.
4. Set an appropriate value for the Content-Type header to tell browsers to display the response as plain text. That is, send back an array '[200, {'Content-Type' => 'text/plain'}, file_contents]'

# Adding Tests

**Requirements**
1. Write tests for the routes that the application already supports. Run them and you should see 2 tests, 12 assertions.

**Implementation**
Things to test:
1. Response status for each link, including all variations of '/file_name'
2. Content types
3. Bodies are in line with what they should be.

# Handling Requests for Nonexistent Documents

**Requirements**
1. When a user attempts to view a document that does not exist, they should be redirected to the index page and shown the message: '$DOCUMENT does not exist.'
2. When the user reloads the index page after seeing an error message, the message should go away.

**Implementation**
0. Enable sessions and determine if the file exists when it is called.
1. Create a conditional within '/:file_name' route for success and failure. In the failure route, set `session[:error]` to the desired text and then redirect to '/'
2. In the layout template, add a conditional above the main content that displays, then deletes the error message, if one is present.

# Viewing Markdown Files

**Requirements**
1. When a user views a document written in Markdown format, the browser should render the rendered HTML version of the document's content.

**Implementation**
1. Add `redcarpet` into Gemfile and run bundle install.
2. Require `redcarpet` in application.
3. Create Redcarpet::Markdown instance and use it to process the text.

**Testing**
1. Assert that the file output is the same as the file, as if it was converted to html
  a. Determine that the response status is 200, as expected.
  b. Determine that the 'Content-Type' header is 'text/html;charset=utf-8'
  c. Determine that the body includes html syntax

# Editing Document Content

**Requirements**
1. When a user views the index page, they should see an "edit" link next to each document name.
2. When the user clicks an edit link, they should be taken to an edit page for the appropriate document.
3. When a user views the edit page for a document, that document's content should appear within a textarea:
4. When a user edits the document's content and clicks a "Save Changes" button, they are redirected to the index page and are shown a message: `$FILENAME has been updated`. 

**Implementation**
1. Steps:
    a. Within `index.erb` a link should be made
    b. The link should get `/$FILENAME/edit_file`
2. Steps:
    a. A template should be made, called `edit_file` 
3. Steps:
    a. The template should contain a textarea element that is prefilled with the contents of the document.
4. Steps:
    a. A "Save Changes" button should be made that sends a post request to `/$FILENAME`. The post request should contain the textarea element changes.
5. In the app file:
    get `/$FILENAME/edit_file`
      needs a variable with the contents of $FILENAME
    post `/$FILENAME`
      Needs to modify the file contents
        read user input
        delete the content in the original file.
        write user input onto the file.
      Needs to save a session['success'] message
      Needs to redirect to '/index'

**Testing**
1. Test that the edit page renders correctly.
    Look for status 200
2. Test that the file is changed after the edit is submitted.
    Change a file and change it back. Test that a change happened.
3. Test that the user is redirected to the index page.
    Test that status 200 is returned
    test that the proper message is rendered.
4. Test that the success message disappears when the index page is reloaded.

# Isolating Test Execution

**Implementation**
1. Update the rest of the tests so they pass after making a change where the testing suite opens its own data directory during tests.
    a. Comment out all the tests and start from the beginning.
    b. Determine if the setup is doing what we want it to do.
        1. Setup should generate a directory within `test` called `data`. This directory should be empty.
    c. Determine if the teardown is doing what we want it to do.
        1. Teardown should delete the `test/data` directory, and all its contents.
    d. Create a method to easily create documents
    e. Recreate tests below:


    test_plain_text_files
        create a `file.txt` file with the content "working on it"
        Get '/file.txt'
        Assert status == 200
        Assert content-type == 'text/plain'
        Assert contents include 'working on it'
    test_file_not_found_message
        get '/file.txt'
        assert status == 302
        get last_response['Location']
        assert status == 200
        assert 'file.txt does not exist.' is present in body

        get '/'
        refute 'file.txt does not exist.' is present in body

    test_viewing_markdown_document
        create 'file.md' with content:
            '# Heading'
        get '/file.md'
        assert response == 200
        assert content-type == 'text/html;charset=utf-8'
        assert '<h1>Heading</h1>' is present in the file

    test_edit_file_page
        create 'file.txt'
        get '/file.txt'
        assert status == 200
        assert body includes '<textarea>'
        assert body includes %q(<button type="submit")

    test_updating_document
        create 'file.txt'
        modify post to '/file.txt'

# Adding Global Style and Behavior

**Requirements**
1. When a message is displayed to a user, that message should appear against a yellow background.
2. Messages should disappear if the page they appear on is reloaded.
3. Text files should continue to be displayed by the browser as plain text.
4. The entire site (including markdown files, but not text files) should be displayed in sans-serif typeface and there should be some padding around the borders of the text.

**Implementation**
1. Create a main.css document in a stylesheets dir.
2. link the :layout to that main.css file.
3. Write into the CSS file to make the font-family for everything sans-serif and to add padding to the `html` element
4. Write into the CSS file to make the flash-success and flash-failure class members have a yellow background.

# Sidebar: Favicon Requests

Browsers make requests for an image to be posted alongside the tab header. The image called `favicon.ico` is used by default.

# Creating New Documents

**Requirements**
1. When a user views the index page, they should see a link that says "New Document".
2. When a user clicks on the "New Document" link, they should be taken to a page with a text input labeled "Add a new document:" and a submit button labeled "Create".
3. When a user enters a document name and clicks "Create", they should be redirected to the index page. The name they entered in the form should now appear in the file list. They should see a message that says "$FILENAME was created.", where $FILENAME is the name of the document just created.
4. If a user attempts to create a new document without a name, the form should be re-displayed and a message should say "A name is required.".

**Implementation**
1. Create a button on the index page, at the top, that says "New Document", and which submits a get request to '/new'.
2. Create an erb file called "new.erb" for the creation page. 
    a. Add the text (Add a new document:), textbox (<input>) and button (called Create, which sends a post request to '/index')
3. Write the back end logic for step 3.
    a. A file with the `title` given, must be added to data.
    b. Convert files to '.txt' if not doc type is given.
4. Add the message "$FILENAME was created." to the logic of step 4.
5. Write the logic required to reset the page with the message "A name is required." if there is no name added to the input field in "new.erb".

**Testing**
1. Get '/new' and verify that an input field is present in the body, the status returned was 200, and the format was correct.
2. post a string to '/index', checking the return for a 302 status.
3. Follow the redirection and check for a 200 status, for the string to be present in the body of the page, and the message "$FILENAME has been created" to be present on the page.
4. post an empty string to '/index', verifying a 422 status and that "A name is required" is in the body.

# Deleting Documents

**Requirements**
1. When a user views the index page, they should see a "delete" button next to each document.
2. When a user clicks a "delete" button, the application should delete the appropriate document and display a message: "$FILENAME was deleted."

**Implementation**
1. In 'index.erb', add a button for deletion. Button's form should post to '/:filename/delete'.
2. Create post '/:filename/delete' route that deletes the file ':filename' from the data folder.
3. Create a confirmation message saying "$FILENAME was deleted".

**Testing**
0. Create two files, 'to_delete.txt' and 'not_to_delete.txt'
1. Test that posting to '/to_delete.txt/delete' returns a 302 status.
2. Check the relocation page for.
    status 200
    body that includes 'not_to_delete.txt'
    body that includes 'to_delete.txt was deleted'
3. Reload '/' to check that the message was deleted.

# Signing In and Out

**Requirements**
1. When a signed-out user views the index page of the site, they should see a "Sign In" button.
2. When a user clicks the "Sign In" button, they should be taken to a new page with a sign in form. The form should contain a text input labeled "Username" and a password input labeled "Password". The form should also contain a submit button labeled "Sign In".
3. When a user enters the username "admin" and password "secret" into the sign in form and clicks the "Sign In" button, they should be signed in and redirected to the index page. A message should display that says "Welcome!".
4. When a user enters any other username and password into the sign inform and clicks the "Sign In" button, the sign in form should be redisplayed and an error message "Invalid Credentials" should be shown. The username they entered into the form should appear in the username input.
5. When a signed-in user views the index page, they should see a message at the bottom of the page that says "Signed in as $USERNAME.", followed by a button labeled "Sign Out".
6. When a signed-in user clicks this "Sign Out" button, they should be signed out of the application and redirected to the index page of the site. They should see a message that says "You have been signed out.".

**Implementation**
1. Add a 'sign in' button to the 'index.erb' page. The button should get '/users/signin'
2. Make a signin.erb file that contains a form containing two text inputs and associated labels, Username: and Password:, and also a button that submits the form labeled 'Sign In'. The form should post to '/users/signin'
3. Define the '/users/signin' post route
    a. When the username and password inputted are 'admin' and 'secret', respectively, a session key, :signedin should be set to true. 
    b. Also, session[:message] should be set to 'Welcome!'
    c. Users are then redirected to '/'

    d. If anything else is inputted to the form, redisplay '/users/signin' and display error message "Invalid Credentials".
    e. Display the username they entered into the form in the username box.
4. When session[:signedin] is true, 'index.erb' should have a button named "Sign Out" at the bottom that posts to '/users/signout'.
    a. There, the session[:signedin] should be set to false.
    b. Message "You have been signed out" should then be posted.
    c. User should then be redirected to '/'
    d. Also, when session[:signedin] == true, the sign in button should not be present.

**Testing**
There's a lot here, I feel.
1. Test the '/users/signin' page, looking for appropriate html and status.
2. Test the value of session[:signedin]

# Accessing the Session While Testing

**Requirements**
1. Update all existing tests to use the above methods for verifying session values. This means that many tests will become shorter as assertions can be made directly about the session instead of the content of the response's body. Specifically, instead of loading a page using `get` and then checking to see if a given message is displayed on it, `session[:message]` can be used to access the session value directly.

**Implementation**
1. Every place that checks for a message printed to the body that came from a `session[:message]` being set: change the implementation to calling `get 'path', {}, {'rack.session' => { message: 'the_message' } }
2. Go over the sign in tests to see if something can be modded there.

# Restricting Actions to ONly Signed-in Users

**Requirements**
1. When a signed-out user attempts to perform the following actions, they should be redirected back to the index and shown a message that says "You must be signed in to do that.":
    a. Visit the edit page for a document
    b. Submit changes to a document
    c. Visit the new document page
    d. Submit the new document form
    e. Delete a document

**Implementation**
1. Modify the corresponding routes in cms_test to check for user sign-in status. If present, proceed. If not present, redirect the user to '/' and `session[:message]` should be set to "You must be signed in to do that."
    a. get '/new'
    b. post '/create'
    c. get '/:filename/edit_file'
    d. post '/:filename/edit_file'
    e. post '/:filename/delete'
    f. Make a method that checks for sign in status and performs the redirection necessary if `session[:username]` is nil.

**Testing**
1. Attempt to do all the above without signing in and verify that a redirection to '/' happened and that 'You must be signed in to do that.' was printed.

# Storing User Accounts in an External File

**Requirements**
1. An administrator should be able to modify the list of users who may sign into the application by editing a configuration file using their text editor.

**Implementation**
1. Create a text file that exists in the root directory called 'users.txt'
2. In it, create a list of users, starting with admin that looks like this:
    { username: admin, password: secret }
    { next.. .. }
3. In the post '/users/signin' route, read that file and search for a corresponding string using .include? or a regex or something.

# Storing Hashed Passwords

**Requirements**
1. User passwords must be hashed using bcrypt before being stored so that raw passwords are not being stored anywhere.

**Implementation**
0. Create a get route to 'users/new'
1. Create a route to add users to the site.
    a. Use bcrypt to hash passwords.
    b. Create a User class
    c. Validate the username
        1. Check the YAML file for the same username
        2. Verify that the username isn't empty
    d. Draw up a method to create a user object.
    e. Draw up a method to create a yaml file for a user.
    f. Validate password
2. Create an erb doc called new_user.erb
    a. Username text input
    b. password password input
    c. password confirmation password input
    d. submit button
3. Add a user to the site manually.
4. Check users.yml for the new username and password.
5. Modify '/users/signin' post route to authenticate passwords with bcrypt
6. Add a "Create Account" button to '/' when no user is signed in.
7. Add a prep step to cms_test.rb that creates a users folder in test
8. Modify post '/users/signin' route to reflect changes to user storage.
9. Fix issue with password generation. Should just be the str portion that is saved to the yaml file.
10. Change post '/users/signin' to work with the new structure.
    a. Access the users directory
    b. Obtain an array of the user objects.
    c. Compare parameter username and password to the objects in the array.
        Make sure to compare using BCrypt
    d. If an object is found with the same username and password, sign the user in.
        1. Set `session[:curr_usr]` to the username
        2. Set `session[:message]` to 'Welcome!
    e. Else status 422 and etc.
