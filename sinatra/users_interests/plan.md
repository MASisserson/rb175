Requirements
1. When a user loads the home page, they should be redirected to a page that lists all of the users' names. Load the users from the users.yaml file (content below).
  a. "/" => "/users"
  b. Make links in the template, iterate through `@usernames`
2. Each of the users' names should be a link to a page for that user.
  a. erb file for '/users' template needs links to user pages.
  b. Need a method to iterate through the names in the yaml file (in `before do`). Create an array of usernames or something in a `before do` method. Also save an instance variable to the yaml user hash.

3. On each user's page, display their email address. Also display their interests, with a comma appearing between each interest.
  a. Has to be way to autogenerate user page '/users/#{username}'
  b. Iterate through the array of usernames until a match is found, then reference the YAML file for the other information.

4. At the bottom of each user's page, list links to all of the other users pages. Do not include the user whose page it is in this list.
  a. Reference yaml users array in .rb file to create an array of users that doesn't include the page's owner. Pass that array to the '/users/#{username}' template to display at the bottom.

5. Add a layout to the application. At the bottom of every page, display a message like this: "There are 3 users with a total of 9 interests."
  a. Add an @interests array to the `do before` method, that we can use to return a quantity.
  b. For the users, check the @users array in `do before`

6. Update the message printed out in req 5 to determine the number of users and interests based on the content of the YAML file. Use a helper method, count_interests, to determine the total number of interests across all users.
  a. Move that counting in (a) above to a helper method `count_interests`

7. Add a new user to the users.yaml file. Verify that the site updates accordingly.

Files and directories I need:

user_interests.rb
data
  users.yaml
Gemfile
Gemfile.lock
plan.md
public
  stylesheets
    user_interests.css
test.rb
views
  layout.erb
  users.erb ( "/users" )
  specific_user.erb ( "/users/#{name}" )
  