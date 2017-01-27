require 'socket'
require_relative '../RubymineProjects/betscore/config/environment'

app = Rack::Lint.new(Rails.application)
server = TCPServer.new 5678

while session = server.accept
	request = session.gets
	puts request
	
	http_method, full_path = request.split(' ')
	path, params = full_path.split('?')
	
	input = StringIO.new
        input.set_encoding 'ASCII-8BIT'
	puts path,params
	status, headers, body = app.call({
		'REQUEST_METHOD' => http_method,
		'PATH_INFO' => path,
		'QUERY_STRING' => params || '',
    		'SERVER_NAME' => 'localhost',
	        'SERVER_PORT' => '5678',
		'REMOTE_ADDR' => '127.0.0.1',
	        'rack.version' => [1,3],
	        'rack.input' => input,
       	        'rack.errors' => $stderr,
	        'rack.multithread' => false,
	        'rack.multiprocess' => false,
	        'rack.run_once' => false,
	        'rack.url_scheme' => 'http'
	})
	
	session.print "HTTP/1.1 #{status}\r\n"
	headers.each do |key,value|
		session.print "#{key}: #{value}\r\n"
	end
	session.print "\r\n"
	body.each do |part|
		session.print part
	end
	session.close
end

