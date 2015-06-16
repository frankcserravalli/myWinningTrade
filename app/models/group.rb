# == Schema Information
#
# Table name: groups
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  name       :string(255)
#  created_at :timestamp(6)     not null
#  updated_at :timestamp(6)     not null
#

class Group < ActiveRecord::Base
  attr_accessible :name, :user_id, :group_users_attributes

  has_many :group_users, dependent: :destroy

  belongs_to :user

  accepts_nested_attributes_for :group_users
end
