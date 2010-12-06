require 'rubygems'
gem 'soundcloud-ruby-api-wrapper'
require 'soundcloud'
require 'yaml'



# oAuth setup code:  
# Enter your consumer key and consumer secret values here:

# sandbox
# @consumer_application = {:key => 'I2M7vyfA09dwsghkLCCw', 
#                          :secret => '0txAZvNCG0QWNdRUX0l8HWnmxiRccPwYWPEjctxmI'}
#                          
# @user = {:access_token => "qKopvxFG77snJ0lroDmxbg", 
#          :access_secret => "vaA3H4I514KK0rrjp8nZbgxexXh1Ui6JurIcXHVuWGU"}

# # Set up an oAuth consumer.  
# @consumer = OAuth::Consumer.new @consumer_application[:key], @consumer_application[:secret], 
# {
#   :site               => 'http://api.sandbox-soundcloud.com', 
#   :request_token_path => '/oauth/request_token',
#   :access_token_path  => '/oauth/access_token',
#   :authorize_path     => '/oauth/authorize'
# }


# production
@consumer_application = {:key => 'QrhxUWqgIswl8a9ESYw', 
                         :secret => 'tqsUGUD3PscK17G2KCQ4lRzilA2K5L5q2BFjArJzmK1'}
                         
@user = {:access_token => "eN0941YNAs3P8CzpsBEHQ", 
         :access_secret => "BlDWajKkmc7C3KElrBOjc66AoFv7d5eJ3u8WWaHwiI"}

# Set up an oAuth consumer.  
@consumer = OAuth::Consumer.new @consumer_application[:key], @consumer_application[:secret], 
{
  :site               => 'http://api.soundcloud.com', 
  :request_token_path => '/oauth/request_token',
  :access_token_path  => '/oauth/access_token',
  :authorize_path     => '/oauth/authorize'
}

access_token = OAuth::AccessToken.new(@consumer, @user[:access_token], @user[:access_secret])

# Connect the access tokens to SoundCloud
soundcloud = Soundcloud.register({:access_token => access_token, 
                                  :site => @consumer.site})
puts "Authorized and connected to SoundCloud!"

# This is where the SoundCloud API code starts:
me = soundcloud.User.find_me
puts "You are connected to SoundCloud as: '#{me.username}'"

# genres = ['Alternative', 'Indie', 'HipHop', 'Techno', 'Dubstep']
genres = ['Techno', 'Dubstep', 'Alternative', 'Rock']

n_tracks = 10
data   = Hash.new
genres.each do |genre|
  data[genre] = Hash.new(0)
end

if not File.exists?('data.dat')
  genres.each do |genre|
    
    puts "working on: #{genre}"
    
    # Find the hottest tracks of a genre
    hot_tracks = soundcloud.Track.find(:all,:params => 
      {:order => 'hotness', :limit => n_tracks, "genres" => genre})
    hot_tracks.each do |track|
      track.comments.each do |comment|
        comment.body.split.each do |w|
          if w.length > 3
            data[genre][w.downcase] += 1
          end
        end
      end
    end
  end
  File.open('data.dat', "wb") { |file| Marshal.dump(data, file) }
else
  File.open('data.dat', "rb") { |file| data = Marshal.load(file) }
end

p 'here'

      # TODO vielleicht sollte ich die intersection  abziehen
    
# sort the hash by value, and then print it in this sorted order
genres.each do |genre|
  puts genre
  data[genre] = data[genre].sort{|a,b| a[1]<=>b[1]}.reverse
  data[genre][1..10].each { |word, count|
    puts "   #{word}: #{count}"
  }
end

