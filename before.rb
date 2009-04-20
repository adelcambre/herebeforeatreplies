require 'rubygems'
require 'httparty'
require 'sinatra'

class TwitterUser
  include HTTParty
  format :json

  def self.created_at(name)
    Time.parse(get("http://twitter.com/users/show/#{name}.json")["created_at"])
  end
end

get '/' do
  haml :index
end

get '/:user' do
  @created = TwitterUser.created_at(params[:user])
  if @created < Time.local(2007, 05, 29)
    haml :yes
  else
    haml :no
  end
end

post '/' do
  redirect "/#{params[:username]}"
end

__END__

@@ layout
%html
  = yield

@@ index
%head
  %title Were you here before @replies?
  %link{:rel => "stylesheet", :type => "text/css", :href => "/screen.css", :media => :screen}
%body
  %h1
    %form{:action => "/", :method => "post"}
      %span was
      %input{:name => "username"}
      %span here before @replies?
    
  %p 
    Everyone was here before 
    %a{:href => "http://twitter.com/oprah"}@oprah

  %p 
    The real question is whether you were here before
    %a{:href => "http://blog.twitter.com/2007/05/are-you-twittering-me.html"} @replies

  %p 
    Created by: 
    %a{:href => "http://twitter.com/adelcambre"} @adelcambre
    
@@ yes
%head
  %title== #{params[:user]} was here before @replies
  %link{:rel => "stylesheet", :type => "text/css", :href => "/screen.css", :media => :screen}
%body
  %h1
    %a{:href => "http://twitter.com/#{params[:user]}"}== @#{params[:user]}
    was here before @replies
  
  %p== #{params[:user]} joined on #{@created.to_s}
  
  %p
    %a{:href => "http://twitter.com/home?status=%40#{params[:user]}+was+here+before+%40replies+http%3A%2F%2Fherebeforeatreplies.com+%23herebeforeatreplies"} Twitter This!

  %p 
    Created by: 
    %a{:href => "http://twitter.com/adelcambre"} @adelcambre

@@ no
%head
  %title== #{params[:user]} was not here before @replies
  %link{:rel => "stylesheet", :type => "text/css", :href => "/screen.css", :media => :screen}
%body
  %h1
    %a{:href => "http://twitter.com/#{params[:user]}"}== @#{params[:user]}
    was not here before @replies
  
  %p== #{params[:user]} joined on #{@created.to_s}
  
  %p 
    Created by: 
    %a{:href => "http://twitter.com/adelcambre"} @adelcambre
