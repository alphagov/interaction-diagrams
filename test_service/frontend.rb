#!/usr/bin/env ruby
require 'sinatra'
require 'webrick'
require 'net/http'

set :server, 'webrick'
set :port, 8000

get '/index', :provides => 'text/html' do
  http = Net::HTTP.new('localhost', 9000)
  request = Net::HTTP::Post.new('/logic')
  request.body = {chips: true, gravy: true}.to_json
  request['Content-Type'] = 'application/json'
  request['User-Agent'] = 'Frontend Service Client'
  config = JSON.parse http.request(request).read_body
  "<h1>hello</h1><p>config: #{config.to_s}"
end

