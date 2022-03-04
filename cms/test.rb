# frozen_string_literal: true

File.open('test2.rb', 'w') do |f2|
  f2.puts 'Changed the file'
  f2.close
end
