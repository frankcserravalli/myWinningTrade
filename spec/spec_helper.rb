require 'simplecov'
# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'
require 'vcr'
require 'factory_girl'

require 'database_cleaner'
DatabaseCleaner.strategy = :transaction

VCR.configure do |c|
  c.cassette_library_dir = Rails.root.join('spec', 'responses')
  c.hook_into :fakeweb
  c.ignore_localhost = true
end

module AuthenticationHelper
  def authenticate
    create(:user).tap do |user|
      subject.send('current_user=', user)
    end
  end
end

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  config.before(:suite) do
    FactoryGirl.definition_file_paths = [
      File.join(Rails.root, 'spec', 'factories')
    ]
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
  config.mock_with :mocha

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = false

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"
  config.include FactoryGirl::Syntax::Methods
  config.include AuthenticationHelper
end


def cost_basis(stock_price, stock_volume)
  (((stock_price * stock_volume) + Order::TRANSACTION_FEE) / stock_volume).abs
end

# probably should be using a factory here
def new_buy(stock_price, stock_volume, user, user_stock)
  transaction_total = (stock_price * stock_volume) + Order::TRANSACTION_FEE
  transaction_total *= -1 # negative amount for buys
  buy = Buy.new(user: user, user_stock: user_stock, volume: stock_volume)
  buy.price = stock_price
  buy.value = transaction_total
  buy.save!
  buy
end
