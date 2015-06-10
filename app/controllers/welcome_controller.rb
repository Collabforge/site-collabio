class WelcomeController < ApplicationController
  def index
    if current_user_or_visitor.is_logged_in?
      redirect_to dashboard_path
    end
  end
end
