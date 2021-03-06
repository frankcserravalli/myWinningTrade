namespace :user do
  task :destroy, [:uid] => [:environment] do |t,args|
    user = User.find(args[:uid])
    puts 'No such user.' and return if user.nil?
    
    puts 'Destroyed user.' if user.destroy
  end

  task :set_account_balance, [:uid, :new_balance] => [:environment] do |t,args|
    user = User.find(args[:uid])
    puts 'No such user.' and return if user.nil?

    if user.update_attribute :account_balance, args[:new_balance].to_i
      puts "Account balance was set to $#{args[:new_balance]}"
    end
  end
end