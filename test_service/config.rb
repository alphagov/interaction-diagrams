#!/usr/bin/env ruby
require 'sinatra'
require 'webrick'

set :server, 'webrick'
set :port, 10000

get '/config', :provides => 'application/json' do
  { colour: "red" }.to_json
end

