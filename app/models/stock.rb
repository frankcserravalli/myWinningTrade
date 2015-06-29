# == Schema Information
#
# Table name: stocks
#
#  id     :integer          not null, primary key
#  name   :string(255)
#  symbol :string(7)
#

class Stock < ActiveRecord::Base
  has_many :orders

  structure do
    name 'Apple Inc.', validates: :presence
    symbol 'AAPL', limit: 7, validates: :presence
  end

  attr_accessible :name, :symbol
end
