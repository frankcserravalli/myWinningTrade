# == Schema Information
#
# Table name: subscriptions
#
#  id           :integer          not null, primary key
#  user_id      :integer
#  customer_id  :string(255)
#  payment_plan :string(255)
#  created_at   :timestamp(6)     not null
#  updated_at   :timestamp(6)     not null
#

class Subscription < ActiveRecord::Base
  attr_accessible #none

  structure do
    user_id 1
    customer_id "1234"
    payment_plan "twelve"
  end

  belongs_to :user

  def self.add_customer(user_id, customer_id, payment_plan)
    new_customer = Subscription.new

    new_customer.user_id = user_id

    new_customer.customer_id = customer_id

    case payment_plan
    when "two"
      new_customer.payment_plan = "two month"
    when "six"
      new_customer.payment_plan = "six month"
    when "twelve"
      new_customer.payment_plan = "one year"
    end

    new_customer.save
  end
end
