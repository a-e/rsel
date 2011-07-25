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
    else
      erb view.to_sym
    end
  end
end


if __FILE__ == $0
  Rack::Handler::Mongrel.run TestApp, :Port => 8070
end

