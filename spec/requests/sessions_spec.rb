require 'spec_helper'

describe 'Sessions' do
  xit "should provide methods to create and destroy user sessions" do
    visit "/auth/developer"

    fill_in 'name', with: 'Joe'
    fill_in 'email', with: 'joe@example.com'
    click_button 'Sign In'

    click_link 'accept-terms'
    visit "users/subscription"
    click_button 'Delete Subscription'
    click_button 'Delete Subscription'

    page.should have_selector ".notice", text: "Subscription cancelled."

  end
end
