#!/usr/bin/env ruby
require 'sinatra'
require 'webrick'
require 'net/http'

set :server, 'webrick'
set :port, 9000

post '/logic', :provides => 'application/json' do
  http = Net::HTTP.new('localhost', 10000)
  request = Net::HTTP::Get.new('/config')
  request['User-Agent'] = 'Logic Service Client'
  config = JSON.parse http.request(request).read_body
  config[:logic_added] = true
  config.to_json
end

