class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  # cookies[:attempts] = 0
end
