require "find"

class Methods
  def self.directory_files(starting_directory = '.')
    files = Hash.new
    
    Find.find(starting_directory) do |path|
      files[File.basename(path)] = path if File.file?(path)
    end

    files
  end

  def self.directory_file_paths(starting_directory = '.')
    files = Array.new
    
    Find.find(starting_directory) do |path|
      files << path if File.file?(path)
    end

    files
  end
end