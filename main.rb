require 'rubygems'
require_relative 'bot_controller'

bot_controller = BotController.new

while( bot_controller.tweet )
  begin
    sleep(1200)
  rescue Twitter::Error::TooManyRequests => error
    puts "[ERROR] Twitter::Error::TooManyRequests: #{ $! }"
    sleep(900)
  rescue
    puts "[ERROR] Unknown Error: #{ $! }"
    sleep(900)
  end
end