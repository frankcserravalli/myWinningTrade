require 'spec_helper'

describe 'Sessions' do
  it "should provide methods to create and destroy user sessions" do
    visit "/auth/developer"

    fill_in 'name', with: 'Joe'
    fill_in 'email', with: 'joe@example.com'
    click_button 'Sign In'

    click_link 'accept-terms'
    page.current_path.should == dashboard_path

    visit logout_path
    visit root_path
    page.current_path.should == login_path
  end
end
