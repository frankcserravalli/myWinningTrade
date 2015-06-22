# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20150616211325) do

  create_table "date_time_transactions", :force => true do |t|
    t.integer   "user_stock_id"
    t.integer   "user_id"
    t.integer   "volume",        :limit => 8
    t.string    "order_type"
    t.string    "status",                     :default => "pending"
    t.timestamp "execute_at",    :limit => 6
    t.timestamp "updated_at",    :limit => 6
    t.timestamp "created_at",    :limit => 6
  end

  add_index "date_time_transactions", ["user_id"], :name => "index_date_time_transactions_on_user_id"
  add_index "date_time_transactions", ["user_stock_id"], :name => "index_date_time_transactions_on_user_stock_id"

  create_table "group_users", :force => true do |t|
    t.integer   "group_id"
    t.integer   "user_id"
    t.timestamp "created_at", :limit => 6, :null => false
    t.timestamp "updated_at", :limit => 6, :null => false
  end

  create_table "groups", :force => true do |t|
    t.integer   "user_id"
    t.string    "name"
    t.timestamp "created_at", :limit => 6, :null => false
    t.timestamp "updated_at", :limit => 6, :null => false
  end

  create_table "orders", :force => true do |t|
    t.integer   "user_id"
    t.decimal   "price",                          :precision => 10, :scale => 2
    t.integer   "volume",           :limit => 8
    t.string    "type",             :limit => 15
    t.decimal   "value",                          :precision => 10, :scale => 2
    t.integer   "user_stock_id"
    t.timestamp "created_at",       :limit => 6
    t.timestamp "updated_at",       :limit => 6
    t.decimal   "cost_basis",                     :precision => 10, :scale => 2
    t.integer   "volume_remaining", :limit => 8
    t.decimal   "capital_gain",                   :precision => 10, :scale => 2
  end

  add_index "orders", ["type"], :name => "index_orders_on_type"
  add_index "orders", ["user_id"], :name => "index_orders_on_user_id"
  add_index "orders", ["user_stock_id"], :name => "index_orders_on_user_stock_id"

  create_table "pending_teachers", :force => true do |t|
    t.integer   "user_id"
    t.timestamp "created_at", :limit => 6, :null => false
    t.timestamp "updated_at", :limit => 6, :null => false
  end

  create_table "stocks", :force => true do |t|
    t.string "name"
    t.string "symbol", :limit => 7
  end

  create_table "stop_loss_transactions", :force => true do |t|
    t.integer   "user_stock_id"
    t.integer   "user_id"
    t.integer   "volume",        :limit => 8
    t.string    "order_type"
    t.string    "status",                     :default => "pending"
    t.string    "measure"
    t.decimal   "price_target"
    t.timestamp "executed_at",   :limit => 6
    t.timestamp "updated_at",    :limit => 6
    t.timestamp "created_at",    :limit => 6
  end

  add_index "stop_loss_transactions", ["user_id"], :name => "index_stop_loss_transactions_on_user_id"
  add_index "stop_loss_transactions", ["user_stock_id"], :name => "index_stop_loss_transactions_on_user_stock_id"

  create_table "subscriptions", :force => true do |t|
    t.integer   "user_id"
    t.string    "customer_id"
    t.string    "payment_plan"
    t.timestamp "created_at",   :limit => 6, :null => false
    t.timestamp "updated_at",   :limit => 6, :null => false
  end

  add_index "subscriptions", ["user_id"], :name => "index_subscriptions_on_user_id"

  create_table "user_account_summaries", :force => true do |t|
    t.integer   "user_id"
    t.float     "capital_total",              :default => 0.0
    t.timestamp "created_at",    :limit => 6,                  :null => false
    t.timestamp "updated_at",    :limit => 6,                  :null => false
  end

  add_index "user_account_summaries", ["user_id"], :name => "index_user_account_summaries_on_user_id"

  create_table "user_stocks", :force => true do |t|
    t.integer "user_id"
    t.integer "stock_id"
    t.integer "shares_owned",     :limit => 8,                                :default => 0
    t.decimal "cost_basis",                    :precision => 10, :scale => 2
    t.integer "shares_borrowed",  :limit => 8,                                :default => 0
    t.decimal "short_cost_basis",              :precision => 10, :scale => 2
  end

  add_index "user_stocks", ["stock_id"], :name => "index_user_stocks_on_stock_id"
  add_index "user_stocks", ["user_id"], :name => "index_user_stocks_on_user_id"

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "",        :null => false
    t.string   "encrypted_password",     :default => "",        :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0,         :null => false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "name"
    t.string   "provider"
    t.string   "uid"
    t.decimal  "account_balance",        :default => 50000.0
    t.boolean  "accepted_terms"
    t.boolean  "premium"
    t.boolean  "premium_subscription",   :default => false
    t.string   "group",                  :default => "student"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
