class User < ActiveRecord::Base
  OPENING_BALANCE = 50000
  has_many :orders
  has_many :user_stocks
  has_many :stocks, through: :user_stocks
  has_many :date_time_transactions
  has_many :stop_loss_transactions

  structure do
  	email			       'developers@platform45.com'#, validates: :presence
  	name 			       'Joe Bloggs'
    provider 	       'linkedin', limit: 16, index: true, validates: :presence
    uid 			       '1234', index: true, validates: :presence
    account_balance  :decimal, scale: 2, precision: 10, default: 0.0
    accepted_terms   :boolean, default: false
  end

  attr_protected :account_balance
  after_initialize :create_initial_balance

  def self.find_or_create_from_auth_hash(auth_hash)
    where(provider: auth_hash[:provider], uid: auth_hash[:uid]).first_or_initialize.tap do |user|
  	  user.name = auth_hash[:info][:name] if auth_hash[:info]
  	  user.save
  	end
  end

  def display_name
    (name.blank?)? email : name
  end

  def export_orders_as_csv
    CSV.generate do |csv|
      csv << ['Symbol', 'Name', 'Type', 'Time', 'Volume', 'Bid/Ask Price', 'Net Asset Value', 'Cost Basis', 'Capital Gain/Loss', 'Tax Liability']

      orders.includes(:stock).all.each do |order|
        order.cost_basis = (order.cost_basis.to_f * order.volume.to_f).round(2)
        total_capital_gain = (order.capital_gain.to_f * order.volume.to_f).round(2)
        tax_liability = (order.capital_gain.to_f * 0.3).round(2)
        csv << [order.stock.symbol, order.stock.name, order.type.titleize, order.created_at, order.volume, order.price, order.value.abs, order.cost_basis, total_capital_gain, tax_liability].collect(&:to_s)
      end
    end
  end

  protected
  def create_initial_balance
    self.account_balance ||= OPENING_BALANCE
  end
end

