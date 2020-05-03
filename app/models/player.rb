class Player
  attr_accessor :role, :character, :honor, :resistance, :user, :cards, :weapons_played, :visible_cards

  def initialize(role, character, user, amount_players)
    raise "Error, player must have a valid role" unless role.is_a?(Role)
    raise "Error, player must have a valid character" unless character.is_a?(Character)
    @role = role
    @user = user
    @weapons_played = 0
    @character = character
    @visible_cards = []
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

  def reset_resistance!
    @resistance = initial_resistance
  end

  def inoffensive
    cards.none? || resistance.zero?
  end

  def has_weapon?
    cards.collect(&:weapon?).inject(:|)
  end

  def dead?
    @honor <= 0
  end

  def damage_modifier(defend_from=nil)
    if (defend_from && defend_from.type == :weapon)
      visible_cards.collect(&:damage_modifier).inject(0, :+)
    else
      0
    end
  end

  def take_damage(damage, from_player, defend_from)
    @resistance -= damage + from_player.damage_modifier(defend_from)
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
    1 + visible_cards.collect(&:distance_modifier).inject(0, :+)
  end

  def can_defend?
    cards.collect(&:name).include? :parada # TODO Change to consider if player has stop card or special ability
  end

  def reach_modifier
    0 # TODO: Calculate cards that help player see others closer
  end

  def cleanup_turn
    @weapons_played = 0
  end

  def can_play_weapon?
    @weapons_played < (1 + visible_cards.collect(&:weapons_played_modifier).inject(0, :+))
  end

  def distance(start_index, end_index, game)
    return 0 if start_index == end_index
    total_players = game.players.size
    distance_a = 0
    distance_b = 0
    final_distance = game.players[end_index].final_distance
    reach_modifier = game.players[start_index].reach_modifier

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
    distance + final_distance - reach_modifier
  end

  def discard_card(card_name)
    cards.delete_at(cards.index { |c| c.name.to_s == card_name.to_s })
  end

  def discard_stop_card
    discard_card :parada
  end
end
