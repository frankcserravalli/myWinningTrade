class TermsController < ApplicationController
  before_filter :authenticate_user!
  skip_before_filter :require_acceptance_of_terms


  def show
  end

  def accept
    current_user.update_attribute :accepted_terms, true and redirect_to dashboard_path
  end

end
