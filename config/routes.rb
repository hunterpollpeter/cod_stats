Rails.application.routes.draw do
  root 'dashboard#index'
  get 'dashboard/index', as: 'dashboard'

  get 'player/:platform/:username' => 'player#show', as: 'player'
  get 'player/search' => 'player#search', as: 'player_search'
  get 'player/:platform/:username/mode/:mode' => 'player#mode', as: 'player_mode'
  get 'player/:platform/:username/weapon/:weapon' => 'player#weapon', as: 'player_weapon'
  get 'player/:platform/:username/divisions/:division' => 'player#division', as: 'player_division'
end
