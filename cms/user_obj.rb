# frozen_string_literal: true

# User object for tracking user data.
class User
  attr_reader :username, :password

  def initialize(username, password)
    @username = username
    @password = password
  end
end
