class GroupsController < ApplicationController
  before_filter :redirect_not_signed_in_user

  skip_before_filter :require_login, :require_iphone_login

  skip_before_filter :require_acceptance_of_terms, if: :current_user

  skip_before_filter :load_portfolio, if: :current_user

  def new
    @group = Group.new
  end

  def index
    # Finding the groups that relate only to the ones the teacher created
    @groups = Group.where(user_id: teacher_current_user.id)
  end

  def edit
    @group = Group.find(params[:id])

    @group_users = @group.group_users.includes(:user)
  end

  def show
    @group = Group.find(params[:id])

    @group_users = @group.group_users.includes(:user => :user_account_summary)
  end

  def update

  end

  def destroy
    @group = Group.find(params[:id])

    if @group.delete
      flash[:notice] = "Class deleted!"

    else
      flash[:notice] = "Unable to delete class!"

    end
    redirect_to groups_path
  end

  def create
    @group = Group.create(params[:group])

    if @group # If group was created
      flash[:notice] = "Class Created!"
    else
      flash[:notice] = 'Class was unable to be created!'
    end

    redirect_to groups_path
  end

  # This action is used for our ajax call to return a list of students matching the params[:term]
  def search_students
    unless params[:term].blank?
      @group_users = Array.new

      @group_users_hash = Hash.new

      # Find the group users that match the term AND are students
      group_users = User.where('name LIKE ?', "%#{params[:term]}%").where(group: "student").limit(10)

      # Loop through each user and push them into the instance variables that will be used for the view
      group_users.each do |user|
        @group_users.push user.name

        @group_users_hash[user.id] = user.name
      end

      # Convert to JSON for JS
      @group_users_hash = @group_users_hash.to_json

      @group_users = @group_users.to_json
    end

    # Respond via javascript
    respond_to do |format|
      format.js
    end
  end

  private

  # This method is used to redirect users who are not signed in
  def redirect_not_signed_in_user
    unless teacher_signed_in?
      redirect_to teacher_sign_in_path
    end
  end
end