class Player
  attr_accessor :role, :character, :honor, :resistance, :user, :cards, :weapons_played, :visible_cards

  def initialize(role, character, user, amount_players)
    raise "Error, player must have a valid role" unless role.is_a?(Role)
    raise "Error, player must have a valid character" unless character.is_a?(Character)
    self.role = role
    self.user = user
    self.weapons_played = 0
    self.character = character
    self.visible_cards = []
    initialize_honor(amount_players)
    reset_resistance
  end

  def initialize_honor(amount_players)
    self.honor = role.initial_honor(amount_players)
  end

  def initial_resistance
    character.resistance
  end

  def reset_resistance
    self.resistance = initial_resistance if resistance.nil? || resistance.zero?
  end

  def reset_resistance!
    self.resistance = initial_resistance
  end

  def inoffensive
    cards.none? || resistance.zero?
  end

  def has_weapon?
    cards.collect(&:weapon?).inject(:|)
  end

  def dead?
    self.honor <= 0
  end

  def daimio_points
    cards.select { |c| c.name == :daimio }.size
  end

  def has_bushido?
    visible_cards.collect(&:name).include?(:bushido)
  end

  def discard_bushido
    visible_cards.delete_at(visible_cards.index { |c| c.name == :bushido })
  end

  def damage_modifier(defend_from=nil)
    modifier = defend_from && character.damage_modifier(defend_from.type) || 0
    if (defend_from && defend_from.type == :weapon)
      modifier += visible_cards.collect(&:damage_modifier).inject(0, :+)
    end
    modifier
  end

  def draw_card_after_making_damage?(type)
    character.draw_card_after_making_damage?(type)
  end

  def draw_card_after_receiving_damage?(type)
    character.draw_card_after_receiving_damage?(type)
  end

  def find_visible_card(card_name)
    visible_cards.index { |c| c.name.to_s == card_name }
  end

  def take_damage(damage, from_player, defend_from)
    return unless character.can_be_hurt_by?(defend_from.type)
    previous_resistance = self.resistance
    self.resistance -= character.final_damage(damage + from_player.damage_modifier(defend_from), defend_from.type)
    if self.resistance <= 0
      self.resistance = 0
      self.honor -= 1
      from_player.honor += 1
    end
    return previous_resistance > self.resistance
  end

  def has_cards?
    cards.size > 0
  end

  def base_distance
    inoffensive ? 0 : 1
  end

  def final_distance
    1 + character.distance_modifier + visible_cards.collect(&:distance_modifier).inject(0, :+)
  end

  def can_defend?
    cards.collect(&:name).include? :parada # TODO Change to consider if player has stop card or special ability
  end

  def reach_modifier
    character.reach_modifier
  end

  def cleanup_turn
    self.weapons_played = 0
  end

  def can_play_weapon?(amount_players = 4)
    special_rules_amount = amount_players == 3 && role.is_a?(Shogun) ? 1 : 0
    self.weapons_played < (character.play_weapon_amount + special_rules_amount + visible_cards.collect(&:weapons_played_modifier).inject(0, :+))
  end

  def samurai_team?
    role.is_a?(Shogun) || role.is_a?(Samurai)
  end

  def ninja_team?
    role.is_a? Ninja
  end

  def draw_card_amount
    character.draw_card_amount
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
