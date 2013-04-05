class GroupsController < ApplicationController
  before_filter :redirect_not_signed_in_user

  def index
    @groups = Group.where(user_id: teacher_current_user.id)
  end

  def show
  end

  def edit

  end

  def new
    @group = Group.new
  end

  def search_students

    @group_users = User.where('name LIKE ?', "%#{params[:search]}%")#.paginate(:per_page => 5, :page => params[:page])

    respond_to do |format|
      format.js
    end
  end

  def create
    #Group.create()
  end

  private

  def redirect_not_signed_in_user
    unless teacher_signed_in?
      redirect_to teacher_sign_in_path
    end
  end
end
