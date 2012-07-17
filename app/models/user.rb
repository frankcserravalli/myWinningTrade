class User < ActiveRecord::Base
  structure do
  	email			'developers@platform45.com'#, validates: :presence
  	name 			'Joe Bloggs'
    provider 	'linkedin', limit: 16, index: true, validates: :presence
    uid 			'1234', index: true, validates: :presence
  end

  def self.find_or_create_from_auth_hash(auth_hash)
    where(provider: auth_hash[:provider], uid: auth_hash[:uid]).first_or_initialize.tap do |user|
  	  user.name = auth_hash[:info][:name] if auth_hash[:info]
  	  user.save
  	end
  end

end

