Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  devise_for :users, :skip => [:registrations]

  # Defines the root path route ("/")
  authenticated :user do
    root "home#index", as: :authenticated_root
  end

  devise_scope :user do
    # get "/sign_up" => "devise/registrations#new", as: "new_user_registration" # custom path to sign_up/registration
    get "users/edit" => "devise/registrations#edit", :as => "edit_user_registration"
    put "users" => "devise/registrations#update", :as => "user_registration"
    root to: "devise/sessions#new"
  end
end
