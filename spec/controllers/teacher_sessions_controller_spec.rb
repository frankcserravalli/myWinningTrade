require 'spec_helper'
=begin
describe TeacherSessionsController do

  before :each do
    @teacher = FactoryGirl.create(:user, group: "teacher")
  end

  describe "new" do
    context "on success" do
      it { should render_template(:new)  }
    end
  end

  describe "create" do
    context "on success" do
      describe "should redirect on success to groups#new" do
        @teacher = FactoryGirl.create(:user, group: "teacher")

        post :create, email: @teacher.email, password: @teacher.password

        it { should redirect_to groups_new }
      end

      describe "should assign session id to user id" do
        post :create, email: @teacher.email, password: @teacher.password

        it { should set_session(:id).to(@teacher.id) }
      end

      describe "current user should respond with user's id" do
        post :create, email: @teacher.email, password: @teacher.password

        current_user.should eq @teacher.id
      end
    end

    context "on failure" do
      describe "should redirect back to sign_in" do
        post :create, email: @teacher.email, password: "not the password"

        it { should redirect_to teacher_sign_in }
      end
    end
  end

  describe "destroy" do
    context "on success" do

    end
  end

=end