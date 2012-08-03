class UserStock < ActiveRecord::Base
  belongs_to :user
  belongs_to :stock

  attr_accessible :stock

  structure do
    shares_owned  10**12, default: 0
  end
end
