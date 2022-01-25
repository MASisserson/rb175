require 'yaml'

def count_interests
  interests = Array.new
  @users.each do |name, info|
    info[:interests].each { |interest| interests << interest }
  end
  interests.uniq.count
end

@users = YAML.load(File.read('users.yaml'))

# p users

# usernames = users.map { |name, info| name.to_s }
# p usernames

p count_interests