class PagesController < HighVoltage::PagesController
  skip_before_filter :require_login
  layout :layout_for_page

  def layout_for_page
    %w(terms).include?(params[:id]) ? params[:id] : 'base'
  end
end
