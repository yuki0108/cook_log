Rails.application.routes.draw do
  root to: 'static_pages#home'
  get :about, to: 'static_pages#about'
  get :use_of_terms, to: 'static_pages#terms'
end
