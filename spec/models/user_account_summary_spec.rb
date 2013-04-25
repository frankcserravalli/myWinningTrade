require 'spec_helper'

describe UserAccountSummary do
  it { should allow_mass_assignment_of(:user_id) }

  it { should allow_mass_assignment_of(:capital_total) }
end
