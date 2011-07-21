#!/usr/bin/env ruby

require 'rubygems'
require 'sinatra/base'
require 'rack'
require 'erb'

class TestApp < Sinatra::Base
  set :root, File.dirname(__FILE__)
  set :static, true

  get '/' do
    erb :index
  end

  get '/about' do
    erb :about
  end

  get '/form' do
    erb :form
  end

  get '/thanks' do
    erb :thanks
  end

  # Allow shutting down the app with a request
  get '/shutdown' do
    Process.kill('KILL', Process.pid)
  end
end


if __FILE__ == $0
  Rack::Handler::Mongrel.run TestApp, :Port => 8070
end

