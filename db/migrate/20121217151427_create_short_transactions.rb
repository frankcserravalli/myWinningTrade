class CreateShortTransactions < ActiveRecord::Migration
  def change
    create_table :short_transactions do |t|

      t.timestamps
    end
  end
end
