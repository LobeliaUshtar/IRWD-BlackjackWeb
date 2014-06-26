require 'rubygems'
require 'sinatra'

set :sessions, true

get '/' do
  erb :username
end

post '/username' do
  session[:user_name] = params[:user_name].capitalize
  redirect '/game'
end

get '/game' do
  erb :game
end