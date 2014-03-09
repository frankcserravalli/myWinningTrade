require 'spec_helper'

describe "Users" do

  describe "Delete Subscriptions" do
    xit "should delete user and show flash message" do
      visit "/auth/developer"

      fill_in 'name', with: 'Joe'
      fill_in 'email', with: 'joe@example.com'
      click_button 'Sign In'

      click_link 'accept-terms'
      page.current_path.should == dashboard_path

      click_button 'Delete Subscription'
      click_button 'Delete Subscription'
      page.should have_selector ".alert", text: "Subscription cancelled."
    end
  end
end