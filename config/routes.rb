Rails.application.routes.draw do

  # This makes our index view the homepage.
  root 'posts#index'

  # This builts routes using REST model.
  resources :posts
  
  
end
