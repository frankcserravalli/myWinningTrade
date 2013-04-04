class Group < ActiveRecord::Base
  attr_accessible :name, :user_id, :group_users_attributes

  has_many :group_users

  accepts_nested_attributes_for :group_users
end
