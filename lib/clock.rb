require File.expand_path(__FILE__)+ '/../../config/environment'
require File.expand_path(__FILE__)+ '/../../config/boot'
require 'rubygems'
require 'clockwork'
include Clockwork

handler do |job|
  puts "Running #{job}"
end

puts "testing clockwork!"
every(60.seconds, 'StopLossTransaction.cron_check'){
  StopLossTransaction.evaluate_pending_orders
}
