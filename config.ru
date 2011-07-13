require 'net/http'
require 'uri'

app = proc do |env|
  request = Rack::Request.new(env)
  
  if request.post?
    
    url = URI.parse(request.params["custom"])
    
    if url.path  == "/"
      path = request.fullpath # use request path is custom url does provide a path
    else
      path = url.path # override if not '/'
    end
    
    forward_request = Net::HTTP::Post.new(path)
    forward_request.basic_auth url.user, url.password if url.user
    forward_request.body_stream = request.body
    forward_request.content_type = request.content_type
    forward_request.content_length = request.content_length
    
    response = Net::HTTP.start(url.host, url.port) { |http| http.request(forward_request) }
    
    return [200, { "Content-Type" => "text/html" }, response.body]
  end
  
  [400, { "Content-Type" => "text/html" }, "Bad Request"]
end

run app