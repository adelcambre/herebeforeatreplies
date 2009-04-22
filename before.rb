require 'rubygems'
require 'httparty'
require 'sinatra'
require 'yaml'

class TwitterUser
  include HTTParty
  class Error < StandardError; end
  format :json
  
  def self.load_creds(file="creds.yml")
    unless File.exists?(file)
      return
    end
    @@credentials = YAML.load_file(file)["credentials"]
    basic_auth @@credentials["username"], @@credentials["password"]
  end
  
  base_uri 'twitter.com'

  def self.created_at(name)
    user = show(name)
    if user["error"] == "Not found"
      return nil
    elsif user["error"]
      raise Error, user["error"]
    end
    Time.parse(user["created_at"])
  end
  
  def self.show(name)
    get("/users/show/#{name}.json")
  end
end

TwitterUser.load_creds

get '/' do
  haml :index
end

get '/:user' do
  begin
    @created = TwitterUser.created_at(params[:user])
    if @created and @created < Time.local(2007, 05, 29)
      haml :yes
    elsif @created
      haml :no
    else
      haml :not_found
    end
  rescue TwitterUser::Error => e
    haml "%h1 An error occurred: #{e.message}"
  end
end

post '/' do
  redirect "/#{params[:username]}"
end

__END__

@@ layout
%html
  %head
    %title Were you here before @replies?
    %link{:rel => "stylesheet", :type => "text/css", :href => "/screen.css", :media => :screen}
  %body
    .content
      = yield
    .footer
      %p 
        Created by
        %a{:href => "http://twitter.com/adelcambre"} @adelcambre
        \, source code on 
        %a{:href => "http://github.com/adelcambre/herebeforeatreplies"} github

    :javascript
      var gaJsHost = (("https:" == document.location.protocol) ? "https://ssl." : "http://www.");
      document.write(unescape("%3Cscript src='" + gaJsHost + "google-analytics.com/ga.js' type='text/javascript'%3E%3C/script%3E"));

    :javascript
      try {
      var pageTracker = _gat._getTracker("UA-8458289-1");
      pageTracker._trackPageview();
      } catch(err) {}

@@ index
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
  were officially added to twitter.

@@ yes
%h1
  %a{:href => "http://twitter.com/#{params[:user]}"}== @#{params[:user]}
  was here before @replies

%p== #{params[:user]} joined on #{@created.to_s}

%p
  %a{:href => "http://twitter.com/home?status=%40#{params[:user]}+was+here+before+%40replies+http%3A%2F%2Fherebeforeatreplies.com+%23herebeforeatreplies"} Twitter This!

@@ no
%h1
  %a{:href => "http://twitter.com/#{params[:user]}"}== @#{params[:user]}
  was not here before @replies

%p== #{params[:user]} joined on #{@created.to_s}
  
@@ not_found
%h1== @#{params[:user]} doesn't exist on twitter

%p
  %a{:href => "/"} Go Back
