class PlayerController < ApplicationController
  def show
    @player, update_successful = Player.api_get player_params
    render 'player/error', locals: { error: 'Player not found' } unless @player
    if update_successful
      flash[:primary] = "Successfully updated #{@player.username}"
    elsif !update_successful.nil? and !update_successful
      flash[:danger] = 'Unable to update player.'
    end
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

