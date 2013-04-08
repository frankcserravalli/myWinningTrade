class GroupsController < ApplicationController
  before_filter :redirect_not_signed_in_user

  skip_before_filter :require_login, :require_iphone_login

  skip_before_filter :require_acceptance_of_terms, if: :current_user

  skip_before_filter :load_portfolio, if: :current_user

  def index
    @groups = Group.where(user_id: teacher_current_user.id)
  end

  def edit
    @group = Group.find(params[:id])
  end

  def show
    @group = Group.find(params[:id])
  end

  def new
    @group = Group.new
  end

  # This action is used for our ajax call to return a list of users matching a name
  def search_students
      unless params[:search].blank?
        @group_users = []

        # TODO remember to add where clause only selecting students
        group_users = User.where('name LIKE ?', "%#{params[:search].capitalize}%")#.paginate(:per_page => 5, :page => params[:page])

        group_users.each do |user|
          @group_users.push user.name
        end

      end

    respond_to do |format|
      format.js
    end
  end

  def create
    #Group.create()
  end

  private

  # This method is used to redirect users who are not signed in
  def redirect_not_signed_in_user
    unless teacher_signed_in?
      redirect_to teacher_sign_in_path
    end
  end
end
