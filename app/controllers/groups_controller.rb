class GroupsController < ApplicationController
  before_filter :redirect_not_signed_in_user

  def index

  end

  def show

  end

  def edit

  end

  def new

  end

  private

  def redirect_not_signed_in_user
    unless teacher_signed_in?
      redirect_to teacher_sign_in_path
    end
  end
end
