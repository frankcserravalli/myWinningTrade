require 'spec_helper'

describe SubscriptionCustomer do
  it { should_not allow_mass_assignment_of(:user_id) }

  it { should_not allow_mass_assignment_of(:payment_option) }

  it { should belong_to :user }
end
