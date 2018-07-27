class SearchController < ApplicationController
  require 'http'
  require 'json'

  def index
    find_player params[:search] if params[:search]
  end

  def player
    find_player params[:search]
    respond_to do |format|
      format.html { redirect_to search_path }
      format.js {}
    end
  end

  private

  def find_player(gamer_tag)
    results = []
    %w[psn xbl steam].each do |platform|
      player = Player.api_find(platform, gamer_tag, 'wwii')
      results << player if player
    end
    @results = results
  end
end
