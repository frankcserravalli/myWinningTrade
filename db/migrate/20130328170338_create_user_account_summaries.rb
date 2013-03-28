class CreateUserAccountSummaries < ActiveRecord::Migration
  def change
    create_table :user_account_summaries do |t|
      t.integer :user_id
      t.float :capital_gain_percentage

      t.timestamps
    end
    add_index :user_account_summaries, :user_id

  end
end
