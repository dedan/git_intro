require 'rubygems'
gem 'soundcloud-ruby-api-wrapper'
require 'soundcloud'

# this is a comment of josi

# oAuth setup code:  
# Enter your consumer key and consumer secret values here:
@consumer_application = {:key => 'QrhxUWqgIswl8a9ESYw', 
                         :secret => 'tqsUGUD3PscK17G2KCQ4lRzilA2K5L5q2BFjArJzmK1'}


# Set up an oAuth consumer.  
@consumer = OAuth::Consumer.new @consumer_application[:key], @consumer_application[:secret], 
{
  :site               => 'http://api.soundcloud.com', 
  :request_token_path => '/oauth/request_token',
  :access_token_path  => '/oauth/access_token',
  :authorize_path     => '/oauth/authorize'
}


# Set the oAuth authorize URL.  
@authorize_url = 'http://soundcloud.com/oauth/authorize?oauth_token='

# Obtain an oAuth request token
puts "Get request token"
request_token = @consumer.get_request_token
p request_token

# Go to URL (in a platform correct browser) and authorize the request token
# Note:  When logging into the sandbox, please use your username, rather than your email.  
puts "Opening: #{@authorize_url + request_token.token}"
if RUBY_PLATFORM =~ /darwin|linux|mswin|mingw|bccwin|wince|emx/
    if RUBY_PLATFORM =~ /darwin/
      `open #{@authorize_url + request_token.token}`
    elsif RUBY_PLATFORM =~ /linux/ && `which firefox` != ""
      `firefox #{@authorize_url + request_token.token}`
    elsif RUBY_PLATFORM =~ /mswin|mingw|bccwin|wince|em/ 
      `start #{@authorize_url + request_token.token}`
    end
  else
      puts "Please open #{@authorize_url + request_token.token} in a web browser.  "
  end
   
# Get the oAuth verifier from the user.
puts "Enter the 6 digit authorization code here"
oauth_verifier = gets.chomp

# Get the access token
access_token = request_token.get_access_token(:oauth_verifier => oauth_verifier)
puts "access_token_key    #{access_token.token}"
puts "access_token_secret #{access_token.secret}"

# Connect the access tokens to SoundCloud
soundcloud = Soundcloud.register({:access_token => access_token, :site => @consumer.site})
puts "Authorized and connected to SoundCloud!"


# This is where the SoundCloud API code starts:
me = soundcloud.User.find_me
puts "You are connected to SoundCloud as: '#{me.username}'"

puts "Uploading track..."
track = soundcloud.Track.create(
  :title      => "Uploaded With The SoundCloud API",
  :asset_data => File.new(path_to_audio_file))

puts "New track '#{track.title}' is now available at #{track.permalink_url}"