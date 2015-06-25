# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  name                   :string(255)
#  provider               :string(255)
#  uid                    :string(255)
#  account_balance        :decimal(, )      default(50000.0)
#  accepted_terms         :boolean
#  premium                :boolean
#  premium_subscription   :boolean          default(FALSE)
#  group                  :string(255)      default("student")
#  pending_teacher_id     :integer
#

require 'spec_helper'
require 'ostruct'

describe User do
  let(:facebook) do
    OpenStruct.new(
      provider: 'facebook', uid: '121322342341',
      info: OpenStruct.new(
        first_name: 'Eric', last_name: 'Santos',
        email: 'test@test.com'))
  end
  let(:google) do
    OpenStruct.new(
      provider: 'google', uid: '121322342341',
      info: OpenStruct.new(
        first_name: 'Eric', last_name: 'Santos',
        email: 'test@test.com'))
  end
  let(:basic_facebook) do
    OpenStruct.new(
      provider: 'facebook', uid: '08797675646542',
      info: OpenStruct.new(username: 'eruco'))
  end
  let(:linkedin) do
    OpenStruct.new(
      provider: 'linkedin', uid: 'udygfwjh',
      info: OpenStruct.new(
        first_name: 'Eric', last_name: 'Santos',
        email: 'test@test.com'))
  end
  it "should receive an initial account balance when being created" do
    User.new.account_balance.should == User::OPENING_BALANCE
  end

  it "upgrade_subscription method should turn user's premium subscription to true" do
    @user = FactoryGirl.create(:user)

    @user.upgrade_subscription

    @user.premium_subscription.should.eql? true
  end

  it "cancel_subscription method should turn user's premium subscription to false" do
    @user = FactoryGirl.create(:user, premium_subscription: true)

    @user.cancel_subscription

    @user.premium_subscription.should.eql? false
  end

  it { should have_one(:subscription) }

  it { should_not allow_mass_assignment_of(:account_balance) }

  it "add appropriate account bonus of an extra $25,000" do
    @user = FactoryGirl.create(:user, premium_subscription: true)

    @user.add_capital_to_account("option-1-bonus")

    @user.account_balance.should eq 75_000
  end

  it "add appropriate account bonus of an extra $500,000" do
    @user = FactoryGirl.create(:user, premium_subscription: true)

    @user.add_capital_to_account("option-5-bonus")

    @user.account_balance.should eq 550_000
  end

  describe 'Omniauth' do
    describe 'facebook login' do
      context 'when user doesnt exist' do
        before(:each) do
          User.all.each do |user|
            user.destroy
          end
        end
        it 'creates a user' do
          expect do
            User.from_omniauth(facebook)
          end.to change(User, :count).by(1)
        end
        it 'returns a user' do
          user = User.from_omniauth(facebook)
          expect(user).to be_a(User)
        end
        it 'has facebook as provider' do
          user = User.from_omniauth(facebook)
          expect(user.provider).to eq('facebook')
        end
        it 'has a facebook id' do
          user = User.from_omniauth(facebook)
          expect(user.uid).not_to eq(nil)
        end
      end
      context 'when user exist' do
        before(:each) do
          User.from_omniauth(facebook)
        end
        it 'finds a user' do
          expect do
            User.from_omniauth(facebook)
          end.to change(User, :count).by(0)
        end
        it 'returns a user' do
          user = User.from_omniauth(facebook)
          expect(user).to be_a(User)
        end
        it 'has facebook as provider' do
          user = User.from_omniauth(facebook)
          expect(user.provider).to eq('facebook')
        end
        it 'has a facebook id' do
          user = User.from_omniauth(facebook)
          expect(user.uid).not_to eq(nil)
        end
      end
    end

    describe 'linkedin login' do
      context 'when user doesnt exist' do
        before(:each) do
          User.all.each do |user|
            user.destroy
          end
        end
        it 'creates a user' do
          expect do
            User.from_omniauth(linkedin)
          end.to change(User, :count).by(1)
        end
        it 'returns a user' do
          user = User.from_omniauth(linkedin)
          expect(user).to be_a(User)
        end
        it 'has facebook as provider' do
          user = User.from_omniauth(linkedin)
          expect(user.provider).to eq('linkedin')
        end
        it 'has a facebook id' do
          user = User.from_omniauth(linkedin)
          expect(user.uid).not_to eq(nil)
        end
      end
      context 'when user exist' do
        before(:each) do
          User.from_omniauth(linkedin)
        end
        it 'finds a user' do
          expect do
            User.from_omniauth(linkedin)
          end.to change(User, :count).by(0)
        end
        it 'returns a user' do
          user = User.from_omniauth(linkedin)
          expect(user).to be_a(User)
        end
        it 'has facebook as provider' do
          user = User.from_omniauth(linkedin)
          expect(user.provider).to eq('linkedin')
        end
        it 'has a facebook id' do
          user = User.from_omniauth(linkedin)
          expect(user.uid).not_to eq(nil)
        end
      end
    end

    describe 'google login' do
      context 'when user doesnt exist' do
        before(:each) do
          User.all.each do |user|
            user.destroy
          end
        end
        it 'creates a user' do
          expect do
            User.from_omniauth(google)
          end.to change(User, :count).by(1)
        end
        it 'returns a user' do
          user = User.from_omniauth(google)
          expect(user).to be_a(User)
        end
        it 'has google as provider' do
          user = User.from_omniauth(google)
          expect(user.provider).to eq('google')
        end
        it 'has a google id' do
          user = User.from_omniauth(google)
          expect(user.uid).not_to eq(nil)
        end
      end
      context 'when user exist' do
        before(:each) do
          User.from_omniauth(google)
        end
        it 'finds a user' do
          expect do
            User.from_omniauth(google)
          end.to change(User, :count).by(0)
        end
        it 'returns a user' do
          user = User.from_omniauth(google)
          expect(user).to be_a(User)
        end
        it 'has google as provider' do
          user = User.from_omniauth(google)
          expect(user.provider).to eq('google')
        end
        it 'has a google id' do
          user = User.from_omniauth(google)
          expect(user.uid).not_to eq(nil)
        end
      end
    end

    describe 'facebook login and linkedin login collision' do
      context 'when logs with facebook and then with linkedin' do
        before(:each) do
          User.all.each do |user|
            user.destroy
          end
        end
        it 'has linkedin as provider' do
          user = User.from_omniauth(facebook)
          user = User.from_omniauth(linkedin)
          expect(user.provider).to eq('linkedin')
        end
        it 'doesnt add a new user' do
          User.from_omniauth(facebook)
          User.from_omniauth(linkedin)
          expect { User.from_omniauth(linkedin) }.to change(User, :count).by(0)
        end
      end
      context 'when logs with linkedin and then with facebook' do
        before(:each) do
          User.all.each do |user|
            user.destroy
          end
        end
        it 'has facebook as provider' do
          User.from_omniauth(linkedin)
          user = User.from_omniauth(facebook)
          expect(user.provider).to eq('facebook')
        end
        it 'doesnt add a new user' do
          User.from_omniauth(linkedin)
          User.from_omniauth(facebook)
          expect { User.from_omniauth(linkedin) }.to change(User, :count).by(0)
        end
      end
    end
  end
end
