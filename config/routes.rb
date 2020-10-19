Rails.application.routes.draw do
  root to: 'static_pages#home'
  get 'sessions/new'
  get :about, to: 'static_pages#about'
  get :use_of_terms, to: 'static_pages#terms'
  get :signup,       to: 'users#new'
  get    :login,     to: 'sessions#new'
  post   :login,     to: 'sessions#create'
  delete :logout,    to: 'sessions#destroy'
  resources :users do
    member do
      get :following, :followers
    end
  end
  resources :dishes
  resources :relationships, only: [:create, :destroy]
end
