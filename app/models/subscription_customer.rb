class SubscriptionCustomer < ActiveRecord::Base
  attr_accessible #none

  belongs_to :user

  def self.add_customer(user_id, customer_id, payment_plan)
    new_customer = SubscriptionCustomer.new

    new_customer.user_id = user_id

    new_customer.customer_id = customer_id

    new_customer.payment_plan = payment_plan

    new_customer.save
  end
end
