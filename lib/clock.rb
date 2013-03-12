require File.expand_path(__FILE__)+ '/../../config/environment'
require File.expand_path(__FILE__)+ '/../../config/boot'
require 'rubygems'
require 'clockwork'
include Clockwork

handler do |job|
  puts "Running #{job}"
end

every(60.seconds, 'evaluating stop loss orders...'){
  StopLossTransaction.evaluate_pending_orders
  Rails.logger.info "cron_check date time working"
}
every(60.seconds, 'evaluating date time orders...'){
  DateTimeTransaction.evaluate_pending_orders
  Rails.logger.info "cron_check date time working"
}
