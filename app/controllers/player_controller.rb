class PlayerController < ApplicationController
  def show
    @player, update_successful, update_message = Player.find_player_or_update(params[:platform], params[:username], 'wwii', params[:force_update])
    unless @player
      redirect_back(fallback_location: root_path, flash: { danger: "Player \"#{params[:username]}\" not found" }) and return
    end
    if update_successful
      flash.now[:success] = update_message
    elsif !update_successful.nil? and !update_successful
      flash.now[:danger] = update_message
    end
  end

  def search
    params = player_params
    redirect_to player_path(params[:platform], params[:username])
  end

  def mode
    @player = Player.find_player params[:platform], params[:username], 'wwii'
    @mode = @player.mode mode_params
  end

  def weapon
    @player = Player.find_player params[:platform], params[:username], 'wwii'
    @weapon = @player.weapon weapon_params
  end

  def division
    @player = Player.find_player params[:platform], params[:username], 'wwii'
    @division = @player.division division_params
  end

  private

  def player_params
    params.require :platform
    params.require :username
    params.permit :force_update, :platform, :username
  end

  def mode_params
    params.require :mode
  end

  def weapon_params
    params.require :weapon
  end

  def division_params
    params.require :division
  end
end

