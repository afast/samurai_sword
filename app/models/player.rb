class Player
  attr_accessor :role, :character, :honor, :resistance, :user, :cards, :weapons_played

  def initialize(role, character, user, amount_players)
    raise "Error, player must have a valid role" unless role.is_a?(Role)
    raise "Error, player must have a valid character" unless character.is_a?(Character)
    @role = role
    @user = user
    @weapons_played = 0
    @character = character
    initialize_honor(amount_players)
    reset_resistance
  end

  def initialize_honor(amount_players)
    @honor = role.initial_honor(amount_players)
  end

  def initial_resistance
    character.resistance
  end

  def reset_resistance
    @resistance = initial_resistance if resistance.nil? || resistance.zero?
  end

  def inoffensive
    cards.none? || resistance.zero?
  end

  def dead?
    @honor <= 0
  end

  def take_damage(damage, from_player)
    @resistance -= damage
    if @resistance <= 0
      @resistance = 0
      @honor -= 1
      from_player.honor += 1
    end
  end

  def has_cards?
    cards.size > 0
  end

  def base_distance
    inoffensive ? 0 : 1
  end

  def final_distance
    1 # TODO: Add card effects here
  end

  def can_defend?
    false # TODO Change to consider if player has stop card or special ability
  end

  def reach_modifier
    0 # TODO: Calculate cards that help player see others closer
  end

  def cleanup_turn
    @weapons_played = 0
  end

  def can_play_weapon?
    @weapons_played.zero? # TODO review special abilities
  end

  def distance(start_index, end_index, game)
    return 0 if start_index == end_index
    total_players = game.players.size
    distance_a = 0
    distance_b = 0

    if end_index < start_index
      aux = start_index
      start_index = end_index
      end_index = aux
    end
    i = start_index + 1
    while (i < end_index) do
      distance_a += game.players[i].base_distance
      i += 1
    end
    i = (start_index.zero? ? total_players : start_index) - 1
    while (i < start_index || i > end_index) do
      distance_b += game.players[i].base_distance
      i -= 1
      i = total_players - 1 if i < 0
    end

    distance = [distance_a, distance_b].min
    distance + game.players[end_index].final_distance - game.players[start_index].reach_modifier
  end
end
