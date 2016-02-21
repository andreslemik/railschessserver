Rails.application.routes.draw do
    devise_for :users
    resources :games, except: [:edit, :update]
    post 'turn/:game/:user/:from/:to' => 'chess#make_turn', as: 'make_turn'
    root to: 'games#index'
end
