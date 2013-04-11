class UserAccountSummary < ActiveRecord::Base
  attr_accessible :capital_total, :user_id

  belongs_to :user

  def self.find_top_results(user_id)
    @world_leader_board = UserAccountSummary.includes(:user).order("capital_total DESC").limit(10)

    @class = GroupUser.find_by_user_id(user_id)

    if @class
      @class_mates = GroupUser.where(group_id: @class.group_id).select("user_id")

      @class_leader_board = UserAccountSummary.where(user_id: @class_mates).includes(:user).order("capital_total DESC").limit(10)
    else
      @class_leader_board = nil
    end

    return [@world_leader_board, @class_leader_board]
  end

end
