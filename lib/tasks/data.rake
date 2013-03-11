require 'faker'

namespace :db do
  desc "Fill database with sample data"

  task :populate => :environment do
    # This line below is commented out because Heroku sucks
    #Rake::Task['db:reset'].invoke

    #For Desired Users To Test
    user = User.new
    user.name = "Joe"
    user.email = "joe@conclavelabs.com"
    user.uid = "1234"
    user.provider = "google"
    user.password = "1234"
    user.password_confirmation = "1234"
    user.save
  end
end