Rails.application.routes.draw do
  mount ActionCable.server => "/cable"

  namespace :auth do
    post "login", to: "auth#create_auth_token"
    post "logout", to: "auth#destroy_auth"
    get "current_user", to: "auth#current_user"
    get "email_exists", to: "auth#email_exists"
  end

  post 'users/create', to: "users#create"
end