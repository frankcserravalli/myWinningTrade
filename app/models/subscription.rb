class Subscription < ActiveRecord::Base
  attr_accessible #none

  belongs_to :user

  def self.add_customer(user_id, customer_id, payment_plan)
    new_customer = Subscription.new

    new_customer.user_id = user_id

    new_customer.customer_id = customer_id

    case payment_plan
    when "two"
      payment_plan = "two month"
    when "six"
      payment_plan = "six month"
    when "twelve"
      payment_plan = "one year"
    end

    new_customer.payment_plan = payment_plan

    new_customer.save
  end
end
