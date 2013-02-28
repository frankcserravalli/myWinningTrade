class SubscriptionCustomer < ActiveRecord::Base
  attr_accessible #none

  belongs_to :user
end
