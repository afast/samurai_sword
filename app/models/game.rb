class Game < ApplicationRecord
  attr_accessor :amount_players, :players, :users, :deck, :discarded

  CHARACTERS = [:benkei, :chiyome, :ginchiyo, :goemon, :hanzo, :hideyoshi, :ieyasu, :kojiro, :musashi, :nobunaga, :tomoe, :ushiwaka]
  CARDS = []

  def determine_roles(amount)
    raise "Error, there should be 4-7 players, #{amount} is an invalid number of players" unless amount >= 4 && amount <= 7
    roles = [Shogun.new, Samurai.new, Ninja.new, Ninja.new]

    case amount
    when 5
      roles << Ronin.new
    when 6
      roles += [Ronin.new, Ninja.new]
    when 7
      roles += [Ronin.new, Ninja.new, Samurai.new]
    end
    roles.shuffle
  end

  def initialize_players
    player_set = CHARACTERS.shuffle.take(@amount_players).zip(determine_roles(@amount_players))
    i=-1
    player_set.map do |character, role|
      i = i+1
      char = character.to_s.capitalize.constantize.new
      Player.new(role, char, @users[i], @amount_players)
    end
  end

  def initialize_cards
    Card.initialize_weapons.shuffle
  end

  def start
    @players = initialize_players
    @deck = initialize_cards
  end
end
