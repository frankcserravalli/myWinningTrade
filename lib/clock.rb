require File.expand_path(__FILE__)+ '/../../config/environment'
require File.expand_path(__FILE__)+ '/../../config/boot'
require 'rubygems'
require 'clockwork'
include Clockwork

handler do |job|
  puts "Running #{job}"
end

puts "testing clockwork!"
every(10.seconds, 'StopLossTransaction.cron_check'){
  puts "aaaaa"
  StopLossTransaction.cron_check
}
