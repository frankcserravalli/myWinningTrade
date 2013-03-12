require File.expand_path(__FILE__)+ '/../../config/environment'
require File.expand_path(__FILE__)+ '/../../config/boot'
require 'rubygems'
require 'clockwork'
include Clockwork

handler do |job|
  puts "Running #{job}"
end

every(60.seconds, 'evaluating stop loss orders...'){
  Delayed::Job.enqueue
  StopLossTransaction.evaluate_pending_orders
  #Rails.logger.add("cron_check date time working, Log Date: #{DateTime.now}")
}
every(60.seconds, 'evaluating date time orders...'){
  Delayed::Job.enqueue
  DateTimeTransaction.evaluate_pending_orders
  #Rails.logger.add("cron_check date time working, Log Date: #{DateTime.now}")
}
