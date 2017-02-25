#! /usr/bin/env ruby

require 'getoptlong'
require 'messageprinter'

def print_help
    puts "driver [AMOUNT] [MESSAGE]"
    puts "AMOUNT: number of milliseconds to wait"
    puts "MESSAGE: message to be displayed after timeout. Needs to be in milliseconds"
end


if ARGV.size != 2
    print_help
else
    amount = ARGV[0].to_i
    message = ARGV[1]
    # Add more error handling
    puts Messageprinter.methods
    Messageprinter.wait_and_print(amount, message)
end
