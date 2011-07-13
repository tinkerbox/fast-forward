require 'net/http'
require 'cgi'

app = proc do |env|
  request = Rack::Request.new(env)
  
  if request.post?
    
    custom_params = {}
    
    request.params["custom"].split(',').each do |pair|
      values = pair.split(':')
      custom_params[CGI::unescape(values[0].strip)] = CGI::unescape(values[1].strip)
    end
    
    response = Net::HTTP.start(custom_params['host'], custom_params['port'] || 80) {|http|
      forward_request = Net::HTTP::Post.new(request.fullpath)
      
      if custom_params['user'] && custom_params['password']
        forward_request.basic_auth custom_params['user'], custom_params['password']
      end
      
      forward_request.body_stream = request.body
      forward_request.content_type = request.content_type
      forward_request.content_length = request.content_length
      
      result = http.request(forward_request)
    }
    
    return [200, { "Content-Type" => "text/html" }, "OK"]
  end
  
  [400, { "Content-Type" => "text/html" }, "Bad Request"]
end

run app