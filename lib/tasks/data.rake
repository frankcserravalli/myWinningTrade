require 'faker'

namespace :db do
  desc "Fill database with sample data"

  task :populate => :environment do
    # This line below is commented out because Heroku sucks
    #Rake::Task['db:reset'].invoke

    #For Desired Users To Test
    30.times do |n|
      user = User.new

      user.name = "Joe"

      user.email = "joe@conclavelabs.com" + n.to_s

      user.uid = "1234"

      user.provider = "google"

      user.password = "1234"

      user.password_confirmation = "1234"

      user.save

      user.accepted_terms = true

      user.account_balance = rand(1..150_000)

      user.save
    end
  end
end