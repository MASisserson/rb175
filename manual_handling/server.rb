require "socket"

def parse_request(request_line)
  http_method, path_and_params, http_ver = request_line.split
  path, params = path_and_params.split("?")
  params = params.split('&').map { |str| str.split('=') }.each_with_object({}) do |(k, v), hash|
    hash[k] = v
  end

  [http_method, path, params]
end

server = TCPServer.new("localhost", 3003)
loop do
  client = server.accept

  request_line = client.gets
  next if !request_line || request_line =~ /favicon/
  puts request_line
  http_method, path, params = parse_request(request_line)

  client.puts "HTTP/1.1 200 OK"
  client.puts "Content-Type: text/html\r\n\r\n"
  
  client.puts "<html>"
  client.puts "<body>"
  client.puts "<pre>"
  client.puts http_method
  client.puts path
  client.puts params
  client.puts "</pre>"

  client.puts "<h1>Rolls!</h1>"
  params["rolls"].to_i.times { client.puts "<p>", (rand(params["sides"].to_i) + 1), "</p>" }

  client.puts "</body>"
  client.puts "</html>"
  client.close
end