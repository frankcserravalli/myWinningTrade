class UserAccountSummary < ActiveRecord::Base
  attr_accessible :capital_gain_percentage, :user_id

  belongs_to :user

  def self.find_top_results(user_id)
    @world_leader_board = UserAccountSummary.order("capital_total DESC").includes(:users).limit(20)

    @class = GroupUser.find_by_user_id(user_id)

    if @class
      @class_leader_board = GroupUser.where(group_id: @class.group_id).includes(:user)
    else
      @class_leader_board = nil
    end

    return [@world_leader_board, @class_leader_board]
  end

end
