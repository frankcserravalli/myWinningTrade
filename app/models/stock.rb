class Stock < ActiveRecord::Base
  has_many :orders

  structure do
    name 'Apple Inc.', validates: :presence
    symbol 'AAPL', limit: 7, validates: :presence
  end

  attr_accessible :name, :symbol
end