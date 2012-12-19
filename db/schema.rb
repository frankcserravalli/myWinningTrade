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

ActiveRecord::Schema.define(:version => 20121214185723) do

  create_table "orders", :force => true do |t|
    t.integer  "user_id"
    t.decimal  "price",                          :precision => 10, :scale => 2
    t.integer  "volume",           :limit => 8
    t.string   "type",             :limit => 15
    t.decimal  "value",                          :precision => 10, :scale => 2
    t.integer  "user_stock_id"
    t.decimal  "cost_basis",                     :precision => 10, :scale => 2
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "volume_remaining", :limit => 8
    t.decimal  "capital_gain",                   :precision => 10, :scale => 2
    t.integer  "user_short_id"
  end

  add_index "orders", ["type"], :name => "index_orders_on_type"
  add_index "orders", ["user_id"], :name => "index_orders_on_user_id"
  add_index "orders", ["user_stock_id"], :name => "index_orders_on_user_stock_id"

  create_table "stocks", :force => true do |t|
    t.string "name"
    t.string "symbol", :limit => 7
  end

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
    t.string  "email"
    t.string  "name"
    t.string  "provider",        :limit => 16
    t.string  "uid"
    t.decimal "account_balance",               :precision => 10, :scale => 2, :default => 50000.0
    t.boolean "accepted_terms",                                               :default => false
  end

  add_index "users", ["provider"], :name => "index_users_on_provider"
  add_index "users", ["uid"], :name => "index_users_on_uid"

end
