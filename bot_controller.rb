require 'twitter'
require_relative 'tea_party_bot'

class BotController
  
  def initialize
    ## Bot user
    @user_screen_name = "TeaPartyBot"
    ## App config settings
    config = {
      consumer_key:        ENV['TEA_PARTY_BOT_CONSUMER_KEY'],
      consumer_secret:     ENV['TEA_PARTY_BOT_CONSUMER_SECRET'],
      access_token:        ENV['TEA_PARTY_BOT_ACCESS_TOKEN'],
      access_token_secret: ENV['TEA_PARTY_BOT_ACCESS_TOKEN_SECRET']
    }
    
    ## Get client
    @client = Twitter::REST::Client.new( config )
    ## Setup bots
    @bots = setup_bots
  end
  
  def tweet
    bot = @bots.first
    5.times do
      success, result = bot.build_text
      if success
        next if duplicate?( result )
        @client.update( result )
        puts result
        break
      else
        puts "ERROR: #{result}"
      end
    end
    true
  end
  
  def duplicate?( result )
    search_str = "from:#{@user_screen_name} #{result}"
    results = @client.search( search_str )
    results.any? ? true : false
  end
  
=begin  
  def duplicate?( text )
    tweets = @client.user_timeline
    tweets.each do |tweet|
      return true if tweet.text == text
    end
    false
  end
=end  
  
  def list
    bot = @bots.first
    success, result = bot.build_text
    if success
      puts result
    else
      puts "ERROR: #{result}"
    end
  end
  
  private
  
  def setup_bots
    bots = []
    bots << TeaPartyBot.new(@client)
    bots
  end

end