class ApplicationController < ActionController::API
  include ActionController::Cookies
  include Authentication
  # middleware.use ActionDispatch::Cookies
end
