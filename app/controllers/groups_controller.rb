class GroupsController < ApplicationController
  before_filter :redirect_not_signed_in_user

  skip_before_filter :require_login, :require_iphone_login

  skip_before_filter :require_acceptance_of_terms, if: :current_user

  skip_before_filter :load_portfolio, if: :current_user

  def new
    @group = Group.new
  end

  def index
    @groups = Group.where(user_id: teacher_current_user.id)
  end

  def edit
    @group = Group.find(params[:id])
  end

  def show
    @group = Group.find(params[:id])
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
    #Group.create()
  end

  # This action is used for our ajax call to return a list of users matching a name
  def search_students
    unless params[:term].blank?
      @group_users = Array.new

      @group_users_hash = Hash.new

      # TODO remember to add where clause only selecting students
      group_users = User.where('name LIKE ?', "%#{params[:term]}%").limit(10)#.paginate(:per_page => 5, :page => params[:page])

      group_users.each do |user|
        @group_users.push user.name

        @group_users_hash[user.id] = user.name
      end


      @group_users_hash = @group_users_hash.to_json

      @group_users = @group_users.to_json
    end

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
