class PlayerController < ApplicationController
  def show
    @player = Player.api_get player_params
    render 'player/not_found' unless @player
  end

  def mode
    @player = Player.api_get player_params
    @mode = mode_params
  end

  def weapon
    @player = Player.api_get player_params
    @weapon = weapon_params
  end

  private

  def player_params
    params.require :id
  end

  def mode_params
    params.require :mode
  end

  def weapon_params
    params.require :weapon
  end
end

