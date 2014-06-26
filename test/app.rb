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

  get '/:view' do |view|
    # Allow shutting down the app with a request
    if view == 'shutdown'
      Process.kill('KILL', Process.pid)
    elsif view == 'slow'
      sleep 5
      erb :slow
    elsif view == '404'
      halt 404, "404: not found"
    elsif view == '500'
      halt 500, "500: server error"
    else
      begin
        erb view.to_sym
      rescue
        halt 404, "404: not found"
      end
    end
  end
end


if __FILE__ == $0
  TestApp.run! :port => 8070
end

