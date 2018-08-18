# For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

Rails.application.routes.draw do
  mount Jumpstart::Engine, at: "/jumpstart"

  scope controller: :static do
    get :about
    get :terms
    get :privacy
  end

  root to: "static#index"
end
