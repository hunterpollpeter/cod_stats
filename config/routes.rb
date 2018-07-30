Rails.application.routes.draw do
  root 'dashboard#index'
  get 'dashboard/index', as: 'dashboard'

  get 'search' => 'search#index'
  get 'search_player' => 'search#player'

  get 'player/:id/mode/:mode' => 'player#mode', as: 'player_mode'
  get 'player/:id/weapon/:weapon' => 'player#weapon', as: 'player_weapon'

  resources :player, only: [:show]
end
