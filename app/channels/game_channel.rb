class GameChannel < ApplicationCable::Channel
  def subscribed
    game = Rails.cache.fetch("game-#{params[:game]}", expires_in: 24.hours) do
      Game.find(params[:game])
    end
    stream_for game
  end

  def speak(game)
    GameChannel.broadcast_to(game, game)
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
