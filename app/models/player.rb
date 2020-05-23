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

  def inoffensive(attack_card=nil)
    resistance.zero? || cards.none? && (attack_card.nil? || !attack_card.damages_even_no_cards?)
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

  def has_herida_sangrante?
    visible_cards.collect(&:name).include?(:herida_sangrante)
  end

  def has_campesinos?
    visible_cards.collect(&:name).include?(:campesino)
  end

  def has_kote?
    visible_cards.collect(&:name).include?(:kote)
  end

  def find_kote
    visible_cards[find_visible_card('kote')]
  end

  def find_herida_sangrante
    visible_cards[find_visible_card('herida_sangrante')]
  end

  def has_maldicion?
    visible_cards.collect(&:name).include?(:maldicion)
  end

  def discard_bushido
    visible_cards.delete_at(visible_cards.index { |c| c.name == :bushido })
  end

  def damage_modifier(defend_from=nil, target=nil)
    modifier = 0
    if defend_from
      modifier += character.damage_modifier(defend_from.type) || 0
      modifier += defend_from.damage_modifier(target)
    end
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

  def take_simple_damage(damage, from_player)
    previous_resistance = self.resistance
    self.resistance -= damage if damage > 0
    if self.resistance <= 0
      self.resistance = 0
      self.honor -= 1
      from_player.honor += 1
      hs_index = self.visible_cards.index { |c| c.name.to_s == 'herida_sangrante' }
      self.visible_cards.delete_at(hs_index) if hs_index
    end
    return previous_resistance > self.resistance
  end

  def take_damage(damage, from_player, defend_from)
    return unless character.can_be_hurt_by?(defend_from)
    previous_resistance = self.resistance
    final_damage = character.final_damage(damage + from_player.damage_modifier(defend_from, self), defend_from.type)
    self.resistance -= final_damage if final_damage > 0
    if self.resistance <= 0
      self.resistance = 0
      if (character == from_player.character && defend_from.add_honor_to_self?)
        self.honor += 1
      else
        self.honor -= 1
        from_player.honor += 1
        hs_index = self.visible_cards.index { |c| c.name.to_s == 'herida_sangrante' }
        self.visible_cards.delete_at(hs_index) if hs_index
      end
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
    character.draw_card_amount + visible_cards.collect(&:draw_additional_cards).inject(0, :+)
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

  def discard_counter_stop
    discard_card :contrataque
  end

  def discard_campesino
    visible_cards.delete_at(visible_cards.index { |c| c.name == :campesino })
  end

  def discard_stop_card
    discard_card :parada
  end

  def handle_gracia
    if character.is_a?(Gracia) && resistance < initial_resistance
      resistance += 1
    end
  end

  def bokuden?
    character.is_a? Bokuden
  end
end
