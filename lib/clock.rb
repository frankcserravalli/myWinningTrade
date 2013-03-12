require File.expand_path(__FILE__)+ '/../../config/environment'
require File.expand_path(__FILE__)+ '/../../config/boot'
require 'rubygems'
require 'clockwork'
include Clockwork

handler do |job|
  puts "Running #{job}"
end

every(60.seconds, 'evaluating stop loss orders...'){
  puts "cron_check stop_loss_t"
  Rails.logger.info "cron_check date time working, Log Date: #{DateTime.now}"
  StopLossTransaction.evaluate_pending_orders
}
every(60.seconds, 'evaluating date time orders...'){
  puts "cron_check stop_loss_t"
  Rails.logger.info "cron_check date time working, Log Date: #{DateTime.now}"
  DateTimeTransaction.evaluate_pending_orders
}
