#! /usr/bin/ruby

require 'getoptlong'

def print_help
    puts "driver [AMOUNT] [MESSAGE]"
    puts "AMOUNT: number of milliseconds to wait"
    puts "MESSAGE: message to be displayed after timeout. Needs to be in milliseconds"
end


if ARGV.size != 3
    print_help
else
    amount = ARGV[1].to_i
    message = ARGV[2]
    # Add more error handling
    TimedMessage.start_timeout(amount, message)
end

