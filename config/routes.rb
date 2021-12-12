Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  devise_for :users, :skip => [:registrations]
  as :user do
    get "/sign_in" => "devise/sessions#new" # custom path to login/sign_in
    # get "/sign_up" => "devise/registrations#new", as: "new_user_registration" # custom path to sign_up/registration
    get 'users/edit' => 'devise/registrations#edit', :as => 'edit_user_registration'
    put 'users' => 'devise/registrations#update', :as => 'user_registration'
  end

  # Defines the root path route ("/")
  root "home#index"
end
