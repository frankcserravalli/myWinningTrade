class UserAccountSummary < ActiveRecord::Base
  attr_accessible :capital_total, :user_id

  belongs_to :user

  def self.find_top_results(user_id)
    world_leader_board = UserAccountSummary.includes(:user).order("capital_total DESC").limit(10)

    the_class = GroupUser.find_by_user_id(user_id)

    if the_class
      the_class_mates = GroupUser.where(group_id: @class.group_id).select("user_id")

      class_leader_board = UserAccountSummary.where(user_id: the_class_mates).includes(:user).order("capital_total DESC").limit(10)
    else
      class_leader_board = nil
    end

    return [world_leader_board, class_leader_board]
  end

end

# Delete the rest of the records. Already deleted orders
#"#{GroupUsers.where(user_id: [16, 1, 3, 144, 400])}"

has_many :user_stocks, :dependent => :destroy
has_many :group_users, :dependent => :destroy
has_many :stocks, through: :user_stocks
has_many :stop_loss_transactions, :dependent => :destroy
has_one :subscription, :dependent => :destroy
has_one :user_account_summary, :dependent => :destroy
has_one :pending_teacher, :dependent => :destroy