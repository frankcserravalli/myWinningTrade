class UserAccountSummary < ActiveRecord::Base
  attr_accessible :capital_gain_percentage, :user_id

  def self.find_top_results(user_id)
    @world_leader_board = UserAccountSummary.order("capital_total DESC").limit(20)

    @class = GroupUser.find_by_user_id(user_id)

    unless @class.blank?
      @class_leader_board = GroupUser.where(group_id: @class.group_id).includes(:user)
    end

    @class_leader_board = nil

    return [@world_leader_board, @class_leader_board]
  end

end
