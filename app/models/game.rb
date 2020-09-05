class Game < ApplicationRecord
  STATUS = {
    waiting: 'WAITING',
    started: 'STARTED',
    ended: 'ENDED'
  }

  has_and_belongs_to_many :users

  serialize :players
  serialize :deck
  serialize :discarded
  serialize :log
  serialize :target
  serialize :users
  serialize :pending_answer
  serialize :defend_from
  serialize :intuicion_list

  CHARACTERS = [:benkei, :chiyome, :ginchiyo, :goemon, :hanzo, :hideyoshi, :ieyasu, :kojiro, :musashi, :nobunaga, :tomoe, :ushiwaka]
  EXPANSION_CHARACTERS = CHARACTERS + [:bokuden, :damachacha, :gracia, :kanbei, :kenshin, :masamune, :motonari, :okuni, :shima, :shingen, :yoshihiro, :yukimura]
  INITIAL_AMOUNT_CARDS = [4, 5, 5, 6, 6, 7, 7, 7]

  after_initialize do |game|
    game.status = STATUS[:waiting] unless game.status
  end

  def determine_roles(amount)
    raise "Error, there should be 4-7 players, #{amount} is an invalid number of players" unless amount >= 2 && amount <= 7
    roles = [Shogun.new, Ninja.new]

    case amount
    when 3
      roles << Ninja.new
    when 4
      roles += [Ninja.new, Samurai.new]
    when 5
      roles += [Ninja.new, Samurai.new, Ronin.new]
    when 6
      roles += [Ninja.new, Samurai.new, Ronin.new, Ninja.new]
    when 7
      roles += [Ninja.new, Samurai.new, Ronin.new, Ninja.new, Samurai.new]
    when 8
      roles += [Ninja.new, Samurai.new, Ronin.new, Ninja.new, Samurai.new, Ronin.new]
    end
    roles.shuffle
  end

  def initialize_players
    character_set = extension ? EXPANSION_CHARACTERS : CHARACTERS
    p character_set.size
    player_set = character_set.shuffle.shuffle.shuffle.take(amount_players).zip(determine_roles(amount_players))
    i=-1
    p player_set
    return player_set.map do |character, role|
      i += 1
      self.turn = i if role.is_a?(Shogun)
      char = character.to_s.capitalize.constantize.new
      Player.new(role, char, users[i], amount_players)
    end
  end

  def initialize_cards
    Card.initialize_cards(extension).shuffle
  end

  def start
    return unless self.status == STATUS[:waiting]
    self.amount_players = users.size
    self.players = initialize_players
    self.deck = initialize_cards
    self.resolve_bushido = false
    self.bushido_in_play = false
    self.game_ended = false
    self.log = [{player: 'System', message: 'Inicio del Juego', type: :info}]
    self.phase = 2
    i = 0
    while i < players.size do
      players[(turn - i) % players.size].cards = deck.slice!(0, INITIAL_AMOUNT_CARDS[i])
      i+= 1
    end
    self.discarded = []
    self.hand = 0
    self.status = STATUS[:started]
    save
  end

  def discard_card(card_name)
    index = current_player.cards.index { |c| c.name.to_s.downcase == card_name  }
    self.discarded << current_player.cards.delete_at(index)
    self.log << { player: current_player.user.username, message: "Descartó #{card_name}", type: :info }
    save
    if current_player.cards.size <= 7
      next_phase
    end
  end

  def current_state
    if self.game_ended
      "Game Ended"
    else
      "#{current_player.character} - #{current_player.role} | Phase #{self.phase}"
    end
  end

  def current_player
    self.players[self.turn]
  end

  def all_other_players
    self.players.slice(0, self.turn) + self.players.slice(self.turn+1, self.players.size-1)
  end

  def all_other_offensive_players
    all_other_players.select { |p| !p.inoffensive }
  end

  def handle_game_end
    self.game_ended = self.players.collect(&:dead?).inject(:|)
    self.samurai_points = 0
    self.ninja_points = 0
    self.ronin_points = 0
    first_ninja=true
    self.players.each do |p|
      case p.role
      when Shogun
        self.samurai_points += p.honor + p.daimio_points
      when Samurai
        self.samurai_points += (self.amount_players % 2 == 0) ? p.honor*2 : p.honor
        self.samurai_points += p.daimio_points
      when Ninja
        if self.amount_players == 4 && first_ninja
          first_ninja = false
          self.ninja_points += p.honor*2
        else
          self.ninja_points += p.honor
        end
        self.ninja_points += p.daimio_points
      when Ronin
        if self.amount_players == 5
          self.ronin_points = p.honor*2
        elsif self.amount_players > 5
          self.ronin_points = p.honor*3
        end
      end
    end

    if current_player.samurai_team? && self.players.select(&:dead?).collect(&:samurai_team?).inject(:|)
      self.samurai_points -= 3
    elsif current_player.ninja_team? && self.players.select(&:dead?).collect(&:samurai_team?).inject(:|)
      self.ninja_points -= 3
    end

    if self.samurai_points > self.ninja_points && self.samurai_points >= self.ronin_points
      self.winning_team = 'Shogun/Samurais'
    elsif self.ninja_points >= self.samurai_points && self.ninja_points >= self.ronin_points
      self.winning_team = 'Ninjas'
    else
      self.winning_team = 'Ronin'
    end
  end

  def draw_cards(player, amount)
    return if self.game_ended
    remaining = self.deck.size < amount ? amount - self.deck.size : 0
    player.cards += self.deck.slice!(0, amount)
    if self.deck.size.zero?
      self.deck = self.discarded.shuffle.shuffle.shuffle
      self.discarded = []
      self.players.map { |p| p.honor -= 1 }
      self.log << { player: current_player.user.username, message: "Se acabo el mazo, todos pierden un punto de honor", type: :info }
      player.cards += self.deck.slice!(0, remaining) if remaining > 0
      handle_game_end
      save
    end
  end

  def discard_cards(amount)
    return if self.game_ended
    remaining = self.deck.size < amount ? amount - self.deck.size : 0
    self.discarded += self.deck.slice!(0, amount)
    if self.deck.size.zero?
      self.deck = self.discarded.shuffle.shuffle.shuffle
      self.discarded = []
      self.players.map { |p| p.honor -= 1 }
      self.log << { player: current_player.user.username, message: "Se acabo el mazo, todos pierden un punto de honor", type: :info }
      self.discarded += self.deck.slice!(0, remaining) if remaining > 0
      handle_game_end
      save
    end
  end

  def handle_deck_zero
    if self.deck.size.zero?
      self.deck = self.discarded.shuffle.shuffle.shuffle
      self.discarded = []
      self.players.map { |p| p.honor -= 1 }
      self.log << { player: current_player.user.username, message: "Se acabo el mazo, todos pierden un punto de honor", type: :info }
      handle_game_end
      save
    end
  end

  def draw_card_from_discard(player, amount)
    return if self.game_ended || self.discarded.none?
    player.cards += self.discarded.slice!(self.discarded.size-1, 1)
  end

  def ieyasu_take_cards
    return if self.game_ended || self.phase != 2 || !current_player.character.is_a?(Ieyasu) || self.discarded.none?
    save
    self.hand += 1 if current_player.role.is_a? Shogun
    current_player.weapons_played = 0
    draw_card_from_discard(current_player, 1)
    amount = current_player.draw_card_amount - 1
    amount += 1 if players.size == 3 && current_player.role.is_a?(Shogun)
    draw_cards(current_player, amount)
    self.log << { player: current_player.user.username, message: "Robo 2 cartas. (1 del monto de descarte)", type: :info }
    next_phase
  end

  def nobunaga_take_card
    return if self.game_ended || !current_player.character.is_a?(Nobunaga) || current_player.resistance <= 1
    draw_cards(current_player, 1)
    current_player.resistance -= 1
    self.log << { player: current_player.user.username, message: "Nobunaga roba 1 carta adicional por 1 de daño", type: :info }
    save
  end

  def shima_ability(character, property_name)
    return if self.game_ended || !current_player.character.is_a?(Shima) || current_player.resistance <= 1
    target = find_player_by_character(character)
    index_of_card_to_steal = target.find_visible_card(property_name)
    if target && index_of_card_to_steal
      current_player.resistance -= 1
      current_player.cards << target.visible_cards.delete_at(index_of_card_to_steal)
      self.last_action = "Habilidad de Shima, robó #{current_player.cards.last.friendly_name} de #{target.user.username}"
      self.log << { player: current_player.user.username, message: self.last_action, type: :info }
    else
      self.last_error = "Error, debe elegir un jugador a quien robar la carta" unless target
      self.last_error = "Error, debe elegir una carta visible" unless index_of_card_to_steal
      self.log << { player: current_player.user.username, message: self.last_error, type: :error }
    end
    save
  end

  def process_phase
    return if self.game_ended
    save
    if self.phase == 1
      if current_player.resistance <= 0
        current_player.reset_resistance
        self.log << { player: current_player.user.username, message: "Recupero Resistencia", type: :info }
      end
    end
    case self.phase
    when 2
      self.hand += 1 if current_player.role.is_a? Shogun
      current_player.weapons_played = 0
      amount = current_player.draw_card_amount
      amount += 1 if players.size == 3 && current_player.role.is_a?(Shogun)
      draw_cards(current_player, amount)
      self.log << { player: current_player.user.username, message: "Robo 2 cartas", type: :info }
    when 4
      if current_player.cards.size > 7
        self.discarded += current_player.cards.slice!(7, Card::WEAPONS.size)
      end
      current_player.cleanup_turn
      next_turn
      next_phase unless current_player.resistance <= 0
    end
    next_phase
  end

  def next_turn
    return if self.game_ended
    self.log << { player: current_player.user.username, message: "Finalizo Turno", type: :info }
    self.turn = (self.turn - 1) % self.amount_players
    self.log << { player: current_player.user.username, message: "Comienzo Turno", type: :info }
    save
  end

  def find_player_by_character(character)
    self.players.detect { |p| p.character.to_s.downcase == character.to_s.downcase }
  end

  def play_card(source_player, card_name, target_player, what_card, accepted=false)
    return if self.game_ended
    self.last_action = nil
    self.last_error = nil
    current_player = find_player_by_character(source_player)
    if target_player
      target = find_player_by_character(target_player)
      target_index = self.players.index(target)
    end
    card_index = current_player.cards.index { |c| c.name.to_s == card_name.downcase }
    card = current_player.cards[card_index]
    case card.type
    when Card::WEAPON
      self.last_error = "Error, no player for index" unless target
      self.last_error = "Error, #{current_player.user.username} no puede jugar mas armas" unless current_player.can_play_weapon?(self.players.size)
      self.last_error = "Error, #{target.user.username} esta inofensivo" if target.inoffensive(card)
      self.last_error = "Error, #{target.user.username} esta demasiado lejos" if current_player.distance(self.turn, target_index, self) > card.distance
      if self.last_error
        self.log << { player: current_player.user.username, message: self.last_error, type: :error }
        save
        return
      end
      self.pending_answer = []
      self.discarded ||= []
      damachacha_skips = false
      if target.character.is_a?(Damachacha)
        if self.deck.size > 1
          discarded_cards = self.deck.slice!(0, 2)
        else
          discarded_cards = self.deck.slice!(0, 1)
          handle_deck_zero
          discarded_cards += self.deck.slice!(0, 1)
        end
        damachacha_skips = discarded_cards[0].symbol == discarded_cards[1].symbol
        self.discarded += discarded_cards
      end
      unless damachacha_skips
        self.wait_for_answer = true
        self.pending_answer << target
        self.last_action = "#{current_player.user.username} atacó a #{target.user.username} con #{card.friendly_name} - Daño base: #{card.damage + current_player.damage_modifier} - esperando respuesta de #{target.user.username}"
        self.log << { player: current_player.user.username, message: self.last_action, type: :info }
        self.target = target
        self.discarded << current_player.cards.delete_at(card_index)
        self.defend_from = card
      else
        self.last_action = "#{current_player.user.username} atacó a #{target.user.username} con #{card.friendly_name}, pero se descartaron dos cartas con mismo símbolo "
        self.log << { player: current_player.user.username, message: self.last_action, type: :info }
      end
      draw_cards(current_player, 1) if current_player.bokuden? && card.templo?
      current_player.weapons_played += 1 unless card.additional_weapon? || current_player.shingen? && card.monte?
      update(players: self.players)
      save
      handle_game_end
    when Card::PROPERTY
      self.defend_from = {}
      case card_name
      when 'bushido'
        if self.bushido_in_play
          self.log << { player: current_player.user.username, message: "Ya hay un Bushido en juego", type: :error }
        else
          target.visible_cards ||= []
          target.visible_cards << current_player.cards.delete_at(card_index)
          self.bushido_in_play = true
          self.last_action = "#{current_player.user.username} jugó #{card.friendly_name} a #{target.user.username}"
          self.log << { player: current_player.user.username, message: self.last_action, type: :info }
        end
      when 'maldicion', 'herida_sangrante'
        target.visible_cards ||= []
        target.visible_cards << current_player.cards.delete_at(card_index)
        self.last_action = "#{current_player.user.username} jugó #{card.friendly_name} a #{target.user.username}"
        self.log << { player: current_player.user.username, message: self.last_action, type: :info }
      else
        current_player.visible_cards ||= []
        current_player.visible_cards << current_player.cards.delete_at(card_index)
        self.last_action = "Bajó #{card.friendly_name} a la mesa"
        self.log << { player: current_player.user.username, message: self.last_action, type: :info }
        save
      end
    when Card::ACTION
      self.defend_from = {}
      case card_name
      when 'respiracion'
        if target
          current_player.reset_resistance!
          draw_cards(target, 1)
          draw_cards(current_player, 1) if current_player.bokuden? && card.templo?
          self.last_action = "Respiracion - #{current_player.character} recupero resistencia y #{target.character} robo una carta"
          self.log << { player: current_player.user.username, message: self.last_action, type: :info }
          self.discarded << current_player.cards.delete_at(card_index)
        else
          self.last_error = "Error, debe elegir un jugador para recibir la carta"
          self.log << { player: current_player.user.username, message: self.last_error, type: :error }
        end
        save
      when 'jiujitsu'
        self.pending_answer = []
        self.last_action = "Jugó Jiu-Jitsu, todos los demas descartan un arma o pierden 1 de resistencia"
        self.log << { player: current_player.user.username, message: self.last_action, type: :info }
        all_other_offensive_players.each do |p|
          self.pending_answer << p
        end
        self.discarded << current_player.cards.delete_at(card_index)
        self.defend_from = card
        save
        handle_game_end
      when 'grito_de_batalla'
        self.pending_answer = []
        self.last_action = "Jugó Grito de Batalla, todos los demas descartan una parada o pierden 1 de resistencia"
        self.log << { player: current_player.user.username, message: self.last_action, type: :info }
        all_other_offensive_players.each do |p|
          self.pending_answer << p
        end
        self.discarded << current_player.cards.delete_at(card_index)
        self.defend_from = card
        save
        handle_game_end
      when 'ceremonia_del_te'
        draw_cards(current_player, 3)
        all_other_players.each { |p| draw_cards(p, 1) }
        draw_cards(current_player, 1) if current_player.bokuden? && card.templo?
        self.last_action = "Jugó Ceremonia del Te, recibe 3 cartas y el resto reciben 1"
        self.log << { player: current_player.user.username, message: self.last_action, type: :info }
        self.discarded << current_player.cards.delete_at(card_index)
        save
      when 'distraccion'
        if target && target.cards.any?
          if target.okuni? && target.has_origami_cards? && !accepted
            self.pending_answer = [target]
            self.defend_from = card
          else
            self.pending_answer = []
            current_player.cards << target.cards.delete(target.cards.sample)
            self.last_action = "Jugó Distracción, roba una carta al azar de la mano de #{target.user.username}"
            self.log << { player: current_player.user.username, message: self.last_action, type: :info }
            self.discarded << current_player.cards.delete_at(card_index)
            handle_kote(card)
          end
        else
          self.last_error = "Error, debe elegir un jugador a quien robar la carta" unless target
          self.last_error = "Error, el jugador no posee cartas" unless target.cards.any?
          self.log << { player: current_player.user.username, message: self.last_error, type: :error }
        end
        save
      when 'geisha'
        if target && (what_card == 'from_hand' && target.cards.any? || what_card != 'from_hand')
          if target.okuni? && target.has_origami_cards? && !accepted
            card.what_card = what_card
            self.pending_answer = [target]
            self.defend_from = card
          else
            self.pending_answer = []
            self.discarded << current_player.cards.delete_at(card_index)
            if what_card == 'from_hand'
              self.discarded << target.cards.delete(target.cards.sample)
              self.last_action = "Jugó Geisha, descartó (al azar) #{self.discarded.last.friendly_name} de la mano de #{target.user.username}"
            else
              self.discarded << target.visible_cards.delete_at(target.find_visible_card(what_card))
              if self.discarded.last.bushido?
                self.bushido_in_play = false
              end
              self.last_action = "Jugó Geisha, descartó #{self.discarded.last.friendly_name} de #{target.user.username}"
            end
            handle_kote(card)
            self.log << { player: current_player.user.username, message: self.last_action, type: :info }
          end
        else
          self.last_error = "Error, debe elegir un jugador a quien robar la carta" unless target
          self.last_error = "Error, debe elegir un jugador con cartas" if what_card == 'from_hand' && target.cards.none?
          self.log << { player: current_player.user.username, message: self.last_error, type: :error }
        end
        save
      when 'intuicion'
        if all_other_offensive_players.size > 0
          self.pending_answer = []
          self.last_action = "Jugó Intuición, todos los demas deben ofrecer una carta para que #{current_player.user.username} elija"
          self.log << { player: current_player.user.username, message: self.last_action, type: :info }
          all_other_offensive_players.each do |p|
            self.pending_answer << p
          end
          self.discarded << current_player.cards.delete_at(card_index)
          self.defend_from = card
        else
          self.last_error = "Error, no hay jugadores ofensivos"
          self.log << { player: current_player.user.username, message: self.last_error, type: :error }
        end
        save
      when 'imitacion'
        if target
          if target.okuni? && target.has_origami_cards? && !accepted
            card.what_card = what_card
            self.pending_answer = [target]
            self.defend_from = card
            self.last_action = "Juega Imitación, para robar #{current_player.cards.last.friendly_name} de #{target.user.username}"
            self.log << { player: current_player.user.username, message: self.last_action, type: :info }
          else
            self.pending_answer = []
            self.discarded << current_player.cards.delete_at(card_index)
            current_player.cards << target.visible_cards.delete_at(target.find_visible_card(what_card))
            self.last_action = "Jugó Imitación, robó #{current_player.cards.last.friendly_name} de #{target.user.username}"
            self.log << { player: current_player.user.username, message: self.last_action, type: :info }
          end
        else
          self.last_error = "Error, debe elegir un jugador a quien robar la carta" unless target
          self.log << { player: current_player.user.username, message: self.last_error, type: :error }
        end
        save
      when 'daimio'
        draw_cards(current_player, 2)
        self.last_action = "Jugó Daimio, recibe 2 cartas"
        self.log << { player: current_player.user.username, message: self.last_action, type: :info }
        self.discarded << current_player.cards.delete_at(card_index)
        save
      when 'ataque_simultaneo'
        if current_player.resistance > 1 && target && target.resistance > 1
          if target.okuni? && target.has_origami_cards? && !accepted
            card.what_card = what_card
            self.pending_answer = [target]
            self.defend_from = card
            self.last_action = "Juega Imitación, para robar #{current_player.cards.last.friendly_name} de #{target.user.username}"
            self.log << { player: current_player.user.username, message: self.last_action, type: :info }
          else
            self.pending_answer = []
            current_player.resistance -= 1
            target.resistance -= 1
            self.last_action = "Jugó Ataque Simultáneo, pierde uno de resistencia y #{target.user.username} también"
            self.log << { player: current_player.user.username, message: self.last_action, type: :info }
            self.discarded << current_player.cards.delete_at(card_index)
            handle_action_after_damage(current_player, target, card)
          end
          save
        else
          self.last_error = "Error, debes tener al menos 2 puntos de resistencia" unless current_player.resistance > 1
          self.last_error = "Error, el jugador atacado debe tener al menos 2 puntos de resistencia" unless target.resistance > 1
          self.log << { player: current_player.user.username, message: self.last_error, type: :info }
        end
      end
    end
    save
  end

  def take_damage(character, campesinos)
    if resolve_bushido
      current_player.honor -= 1 unless current_player.role.is_a?(Shogun) && players.size == 3
      self.discarded << current_player.discard_bushido
      self.log << { player: current_player.user.username, message: "Pierde 1 honor debido a Bushido", type: :info }
      self.bushido_in_play = false
      self.resolve_bushido = false
    elsif self.defend_from.name == :contrataque
      campesino_damage_modifier = campesinos || 0
      index = pending_answer.index { |c| c.character.to_s.downcase == character.downcase  }
      player_to_receive_damage = pending_answer.delete_at index
      player_to_receive_damage = find_player_by_character(player_to_receive_damage.character)
      origin_player = self.defend_from.counter_attack_source
      campesino_damage_modifier.times { self.discarded << player_to_receive_damage.discard_campesino }
      self.wait_for_answer = false if pending_answer.blank?
      self.last_action = "#{player_to_receive_damage.user.username} recibe #{defend_from.damage - campesino_damage_modifier + current_player.damage_modifier(defend_from)} de daño por #{defend_from.friendly_name}"
      self.log << { player: current_player.user.username, message: self.last_action, type: :info }
      if player_to_receive_damage.take_simple_damage(defend_from.damage - campesino_damage_modifier, origin_player)
        handle_action_after_damage(origin_player, player_to_receive_damage, defend_from)
        if current_player.resistance.zero?
          self.log << { player: current_player.user.username, message: 'Pierde ultima resistencia por contrataque, finaliza turno', type: :info }
          next_phase
        end
      end
    else
      campesino_damage_modifier = campesinos || 0
      index = pending_answer.index { |c| c.character.to_s.downcase == character.downcase  }
      player_to_receive_damage = pending_answer.delete_at index
      player_to_receive_damage = find_player_by_character(player_to_receive_damage.character)
      campesino_damage_modifier.times { self.discarded << player_to_receive_damage.discard_campesino }
      self.wait_for_answer = false if pending_answer.blank?
      self.last_action = "#{player_to_receive_damage.user.username} recibe #{defend_from.damage - campesino_damage_modifier + current_player.damage_modifier(defend_from)} de daño por #{defend_from.friendly_name}"
      self.log << { player: current_player.user.username, message: self.last_action, type: :info }
      if player_to_receive_damage.take_damage(defend_from.damage - campesino_damage_modifier, current_player, defend_from)
        handle_action_after_damage(current_player, player_to_receive_damage, defend_from)
      end
    end
    update(players: self.players)
    handle_game_end
    save
  end

  def handle_action_after_damage(current_player, damaged_player, defend_from)
    draw_cards(current_player, 1) if current_player.draw_card_after_making_damage?(defend_from.type)
    draw_cards(damaged_player, 1) if damaged_player.draw_card_after_receiving_damage?(defend_from.type)
    current_player.cards << self.discarded.delete_at(discarded.size - 1) if defend_from.return_card?
    if defend_from.discard_if_damaged?
      self.last_action = "#{damaged_player.user.username} recibe #{defend_from.damage + current_player.damage_modifier(defend_from)} de daño por #{defend_from.friendly_name} - Ahora debe descartar una carta a elección."
      self.log << { player: current_player.user.username, message: self.last_action, type: :info }
      self.pending_answer << damaged_player
      self.defend_from.already_damaged = true
    end
    if damaged_player.has_maldicion?
      if damaged_player.resistance.zero?
        if damaged_player.has_bushido?
          self.bushido_in_play = false
          self.resolve_bushido = false
        end
        self.discarded += damaged_player.visible_cards
        damaged_player.visible_cards = []
      end
    end
    if damaged_player.yukimura?
      reveal_card = self.deck.delete_at(0)
      handle_deck_zero
      return if self.game_ended
      self.discarded << reveal_card
      if reveal_card.origami?
        current_player.take_simple_damage(1, damaged_player)
        self.log << { player: current_player.user.username, message: "Salio origami resolviendo habilidad de Yukimura, #{current_player.user.username} recibe 1 de daño.", type: :info }
      else
        self.log << { player: current_player.user.username, message: "No salió origami resolviendo habilidad de Yukimura.", type: :info }
      end
    end
    if damaged_player.resistance.zero?
      if self.players.collect(&:character).any?(Motonari)
        self.players.each do |p|
          draw_cards(p, 1) if p.character.is_a?(Motonari)
        end
      end
      discard_cards(damaged_player.initial_resistance)
      self.log << { player: current_player.user.username, message: "Discarded cards because #{damaged_player.user.username} lost all resistance", type: :info }
    end
    save
  end

  def play_stop(character)
    index = pending_answer.index { |c| c.character.to_s.downcase == character.downcase  }
    player_to_receive_damage = pending_answer.delete_at index
    player_to_receive_damage = find_player_by_character(player_to_receive_damage.character)
    if pending_answer.blank?
      self.pending_answer = nil
      self.wait_for_answer = false
    end
    self.last_action = "#{current_player.user.username} atacó a #{player_to_receive_damage.user.username} con #{defend_from.friendly_name} pero fue defendido."
    self.log << { player: current_player.user.username, message: self.last_action, type: :info }
    self.discarded << player_to_receive_damage.discard_stop_card
    draw_cards(player_to_receive_damage, 1) if player_to_receive_damage.bokuden? && self.discarded.last.templo?
    save
  end

  def play_counter_stop(character)
    if self.defend_from.name == :contrataque
      self.last_error = "Error, no se puede defender un contrataque con otro contrataque"
      self.log << { player: current_player.user.username, message: self.last_error, type: :error }
    elsif self.defend_from.type != Card::WEAPON
      self.last_error = "Error, solo se puede usar contrataque para defender armas"
      self.log << { player: current_player.user.username, message: self.last_error, type: :error }
    else
      index = pending_answer.index { |c| c.character.to_s.downcase == character.downcase  }
      player_to_receive_damage = pending_answer.delete_at index
      player_to_receive_damage = find_player_by_character(player_to_receive_damage.character)
      self.pending_answer << current_player
      if pending_answer.blank?
        self.pending_answer = nil
        self.wait_for_answer = false
      end
      self.last_action = "#{current_player.user.username} atacó a #{player_to_receive_damage.user.username} con #{defend_from.friendly_name} pero fue contratacado."
      self.log << { player: current_player.user.username, message: self.last_action, type: :info }
      self.discarded << player_to_receive_damage.discard_counter_stop
      self.defend_from = self.discarded.last
      self.defend_from.counter_attack_source = player_to_receive_damage
      draw_cards(player_to_receive_damage, 1) if player_to_receive_damage.bokuden? && self.discarded.last.templo?
      save
    end
  end

  def respond_weapon(character, weapon_name)
    pending_answer.delete_at(pending_answer.index { |c| c.character.to_s.downcase == character.downcase })
    target = find_player_by_character(character)
    if pending_answer.blank?
      self.pending_answer = nil
      self.wait_for_answer = false
    end
    self.last_action = "#{target.user.username} descarto: #{weapon_name.to_s.humanize}"
    self.log << { player: current_player.user.username, message: self.last_action, type: :info }
    self.discarded << target.discard_card(weapon_name)
    draw_cards(target, 1) if target.bokuden? && self.discarded.last.templo?
    save
  end

  def hanzo_ability(character, weapon_name)
    raise "Error, no eres hanzo" unless character == 'hanzo'
    index = pending_answer.index { |c| c.character.to_s.downcase == character.downcase  }
    pending_answer.delete_at index
    target = find_player_by_character(target.character)
    if pending_answer.blank?
      self.pending_answer = nil
      self.wait_for_answer = false
    end
    self.last_action = "#{target.user.username} descarto un arma, #{weapon_name.to_s.humanize}, como parada"
    self.log << { player: current_player.user.username, message: self.last_action, type: :info }
    self.discarded << target.discard_card(weapon_name)
    save
  end

  def kanbei_ability(character, card_name)
    raise "Error, no eres kanbei" unless character == 'kanbei'
    target = find_player_by_character(character)
    discarded_card = target.discard_visible_card(card_name)
    if discarded_card
      pending_answer.delete_at(pending_answer.index { |c| c.character.to_s.downcase == character.downcase  })
      if pending_answer.blank?
        self.pending_answer = nil
        self.wait_for_answer = false
      end
      self.bushido_in_play = false if discarded_card.bushido?
      self.last_action = "#{target.user.username} descarto una propiedad, #{card_name.to_s.humanize}, como parada"
      self.log << { player: current_player.user.username, message: self.last_action, type: :info }
      self.discarded << discarded_card
    else
      self.last_error = "#{target.user.username} intentó descartar, #{card_name.to_s.humanize}, como parada"
      self.log << { player: current_player.user.username, message: self.last_error, type: :error }
    end
    save
  end

  def okuni_ability(character, card_name)
    raise "Error, no eres Okuni" unless character == 'okuni'
    target = find_player_by_character(character)
    discarded_card = target.discard_origami_card(card_name)
    if discarded_card
      self.discarded << current_player.discard_card(self.defend_from.name)
      pending_answer.delete_at(pending_answer.index { |c| c.character.to_s.downcase == character.downcase  })
      if pending_answer.blank?
        self.pending_answer = nil
        self.wait_for_answer = false
      end
      self.last_action = "#{target.user.username} descarto una carta origami, #{card_name.to_s.humanize}, para anular la accion de #{self.defend_from.name.to_s.humanize}"
      self.log << { player: current_player.user.username, message: self.last_action, type: :info }
      self.discarded << discarded_card
    else
      self.last_error = "#{target.user.username} intentó descartar, #{card_name.to_s.humanize}, para anular la accion de #{self.defend_from.name.to_s.humanize}"
      self.log << { player: current_player.user.username, message: self.last_error, type: :error }
    end
    save
  end

  def defend_bushido(weapon_name)
    self.last_action = "Descartó un arma, #{weapon_name.to_s.humanize}, por Bushido"
    self.log << { player: current_player.user.username, message: self.last_action, type: :info }
    self.resolve_bushido = false
    self.discarded << current_player.discard_card(weapon_name)
    draw_cards(current_player, 1) if current_player.bokuden? && self.discarded.last.templo?
    transfer_bushido
    save
  end

  def handle_bushido
    if current_player.has_bushido?
      bushido_action_card = self.deck.delete_at(0)
      handle_deck_zero
      if current_player.masamune? && bushido_action_card.weapon?
        self.discarded << bushido_action_card
        bushido_action_card = self.deck.delete_at(0)
        handle_deck_zero
      end
      if current_player.masamune? && bushido_action_card.weapon?
        self.discarded << bushido_action_card
        bushido_action_card = self.deck.delete_at(0)
        handle_deck_zero
      end
      return if self.game_ended
      self.discarded << bushido_action_card
      if bushido_action_card.weapon?
        if current_player.has_weapon?
          self.log << { player: current_player.user.username, message: "Salio arma resolviendo Bushido, descarta un arma o pierde uno de honor.", type: :info }
          self.resolve_bushido = true
        else
          current_player.honor -= 1
          self.discarded << current_player.discard_bushido
          self.bushido_in_play = false
          self.log << { player: current_player.user.username, message: "Pierde 1 honor debido a Bushido", type: :info }
          handle_game_end
        end
      else
        self.log << { player: current_player.user.username, message: "Bushido - no salió arma, pasa al proximo", type: :info }
        transfer_bushido
      end
    end
    save
  end

  def handle_herida_sangrante
    if current_player.has_herida_sangrante?
      current_player.visible_cards.select { |c| c.name == :herida_sangrante }.size.times do
        reveal_card = self.deck.delete_at(0)
        handle_deck_zero
        if current_player.masamune? && !reveal_card.origami?
          self.discarded << reveal_card
          reveal_card = self.deck.delete_at(0)
          handle_deck_zero
        end
        if current_player.masamune? && !reveal_card.origami?
          self.discarded << reveal_card
          reveal_card = self.deck.delete_at(0)
          handle_deck_zero
        end
        return if self.game_ended
        self.discarded << reveal_card
        if reveal_card.origami?
          if current_player.resistance > 1
            if current_player.has_campesinos?
              self.log << { player: current_player.user.username, message: "Salio origami con Herida Sangrante, dando opcion a jugador de utilizar campesino.", type: :info }
              self.pending_answer = [current_player]
              self.defend_from = current_player.find_herida_sangrante
            else
              current_player.resistance -= 1
              self.log << { player: current_player.user.username, message: "Herida Sangrante - Salio origami, pierde uno de resistencia", type: :info }
            end
          else
            self.log << { player: current_player.user.username, message: "Herida Sangrante - Salio origami, pero solo tiene 1 de resistencia", type: :info }
          end
        else
          self.log << { player: current_player.user.username, message: "Herida Sangrante - No salio origami", type: :info }
        end
      end
      save
    end
  end

  def kote_selected_player(character)
    index = pending_answer.index { |c| c.character.to_s.downcase == current_player.character.to_s.downcase  }
    return unless index
    pending_answer.delete_at index
    target = find_player_by_character(character)
    if pending_answer.blank?
      self.pending_answer = nil
      self.wait_for_answer = false
    end
    self.defend_from = {}
    self.last_action = "#{target.user.username} roba una carta"
    self.log << { player: current_player.user.username, message: self.last_action, type: :info }
    draw_cards(target, 1)
    save
  end

  def handle_kote(card)
    return unless card.koi? && current_player.has_kote?
    self.defend_from = current_player.find_kote
    self.pending_answer = [current_player]
  end

  def propose_for_intuicion(character, card_name)
    return unless self.defend_from.name == :intuicion
    pending_answer.delete_at(pending_answer.index { |c| c.character.to_s.downcase == character.downcase  })
    self.intuicion_list ||= {}
    self.intuicion_list[character] = card_name
    save
  end

  def steal_by_intuicion(character, card_name)
    return unless self.defend_from.name == :intuicion
    target = find_player_by_character(character)
    card_index = target.cards.index { |c| c.name.to_s == card_name.downcase }
    current_player.cards << target.cards.delete_at(card_index)
    self.last_action = "Intuicion, roba #{card_name} de la mano de #{target.user.username}"
    self.log << { player: current_player.user.username, message: self.last_action, type: :info }
    self.defend_from = {}
    self.intuicion_list = {}
    handle_kote(self.discarded.last)
    save
  end

  def transfer_bushido
    next_player.visible_cards << current_player.discard_bushido
  end

  def reset_resistance_for_current_player
    current_player.reset_resistance
  end

  def next_player
    players[(self.turn - 1) % self.amount_players]
  end

  def next_phase
    return if self.game_ended
    case self.phase
    when 1
      self.phase = 2
    when 2
      self.phase = 3
    when 3
      if current_player.cards.size > 7
        self.phase = 4
      else
        next_turn
        if current_player.resistance <= 0
          self.phase = 1
        else
          self.phase = 2
        end
      end
    when 4
      next_turn
      if current_player.resistance <= 0
        self.phase = 1
      else
        self.phase = 2
      end
      current_player.handle_gracia
    end
    if self.phase == 2
      handle_bushido
      handle_herida_sangrante
    end
    save
  end
end
