# encoding: utf-8

require 'weibo2s'
require 'time-ago-in-words'

%w(rubygems bundler).each { |dependency| require dependency }
Bundler.setup
%w(sinatra haml sass).each { |dependency| require dependency }
enable :sessions

#WeiboOAuth2::Config.api_key = ENV['KEY']
#WeiboOAuth2::Config.api_secret = ENV['SECRET']
WeiboOAuth2::Config.redirect_uri = "http://localhost:4567/callback"

get '/' do
  client = WeiboOAuth2::Client.new
  if session[:access_token] && !client.authorized?
    token = client.get_token_from_hash({:access_token => session[:access_token], :expires_at => session[:expires_at]}) 
    p "*" * 80 + "validated"
    p token.inspect
    p token.validated?
    
    unless token.validated?
      reset_session
      redirect '/connect'
      return
    end
  end

  puts "ok 1" if client.respond_to? :statuses
  puts "ok 2" if client.statuses.respond_to? :update
  puts "ok 3" if client.respond_to? :atuses_nono
  puts "ok 4" if client.statuses.respond_to? :atuse

  if session[:uid]
    @user = client.users.show({:uid => session[:uid].to_i})
    @statuses = client.statuses
  end
  haml :index
end

get '/connect' do
  client = WeiboOAuth2::Client.new
  redirect client.authorize_url
end

get '/callback' do
  client = WeiboOAuth2::Client.new
  access_token = client.auth_code.get_token(params[:code].to_s)
  session[:uid] = access_token.params["uid"]
  session[:access_token] = access_token.token
  session[:expires_at] = access_token.expires_at
  p "*" * 80 + "callback"
  p access_token.inspect
  #@user = client.users.show_by_uid(session[:uid].to_i)
  @user = client.users.show({:uid => session[:uid].to_i})
  redirect '/'
end

get '/logout' do
  reset_session
  redirect '/'
end 

get '/screen.css' do
  content_type 'text/css'
  sass :screen
end

post '/update' do
  client = WeiboOAuth2::Client.new
  client.get_token_from_hash({:access_token => session[:access_token], :expires_at => session[:expires_at]}) 
  statuses = client.statuses

  unless params[:file] && (tmpfile = params[:file][:tempfile]) && (name = params[:file][:filename])
    statuses.update({:status => params[:status]})
  else
    status = params[:status] || '图片'
    pic = File.open(tmpfile.path)
    statuses.upload({:status => params[:status], :pic => pic})
  end

  redirect '/'
end

helpers do 
  def reset_session
    session[:uid] = nil
    session[:access_token] = nil
    session[:expires_at] = nil
  end
end
