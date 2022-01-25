require "tilt/erubis"
require "sinatra"
require "sinatra/reloader"

helpers do
  def wrap_paragraphs(array_of_paragraphs)
    anchor_value = 1
    array_of_paragraphs.map do |paragraph|
      anchor_value += 1 
      "<p id=\"paragraph-#{anchor_value}\">#{paragraph}</p>"
    end.join
  end
  
  def read_chapter(num)
    File.read "data/chp#{num}.txt"
  end

  def separate_paragraphs(chapter)
    chapter.split(/\n{2,}/)
  end

  def create_par_arr(query, chap_num)
    results = Array.new
    regex = Regexp.new query
    separate_paragraphs(read_chapter(chap_num)).each_with_index do |txt, idx|
      if txt =~ regex
        match = (txt =~ regex)
        txt.insert((match + query.length), '</strong>')
        txt.insert(match, '<strong>')
        par_info = Hash.new
        par_info[:id] = (idx + 1)
        par_info[:txt] = txt
        results << par_info
      end
    end

    results
  end

  def find_instances_of(query_str)
    search_results = {}
    return search_results if (!query_str || query_str.empty?)

    query = Regexp.new query_str

    (1..12).each do |num|
      if read_chapter(num) =~ query
        chap_hash = Hash.new
        chap_hash[:num] = num
        chap_hash[:title] = @contents[num - 1]
        search_results[chap_hash] = create_par_arr(query_str, num)
      end
    end

    search_results
  end
end

before do
  @contents = File.readlines('data/toc.txt')
end

get "/" do
  @title = "The Adventures of Sherlock Holmes"

  erb :home
end

get "/chapters/:number" do
  chap_num = params[:number].to_i
  
  redirect "/" unless (1..@contents.size).cover? chap_num
  @chapter = wrap_paragraphs(separate_paragraphs(read_chapter(chap_num)))
  @title = "Chapter #{chap_num}: #{@contents[chap_num - 1]}"

  erb :chapter
end

get "/search" do
  @search_results = find_instances_of(params[:query])
  erb :search
end

not_found do
  redirect "/"
end