class GamesController < ApplicationController
  def index
    @game = Game.new
    @game.amount_players = 4
    @game.users = [1,2,3,4]
    @game.start
  end
end
