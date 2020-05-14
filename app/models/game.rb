class Game < ApplicationRecord
  STATUS = {
    waiting: 'WAITING',
    started: 'STARTED',
    ended: 'ENDE'
  }

  has_and_belongs_to_many :users

  #attr_accessor :amount_players, :hand, :turn, :phase, :wait_for_answer, :game_ended, :samurai_points, :ninja_points,
                #:ronin_points, :winning_team
  #attr_accessor :players, :deck, :discarded, :pending_answer, :target, :defend_from, :log, :resolve_bushido, :bushido_in_play

  serialize :players
  serialize :deck
  serialize :discarded
  serialize :log
  serialize :target
  serialize :users
  serialize :pending_answer
  serialize :defend_from

  CHARACTERS = [:benkei, :chiyome, :ginchiyo, :goemon, :hanzo, :hideyoshi, :ieyasu, :kojiro, :musashi, :nobunaga, :tomoe, :ushiwaka]
  INITIAL_AMOUNT_CARDS = [4, 5, 5, 6, 6, 7, 7]

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
    end
    roles.shuffle
  end

  def initialize_players
    player_set = CHARACTERS.shuffle.shuffle.shuffle.take(amount_players).zip(determine_roles(amount_players))
    i=-1
    return player_set.map do |character, role|
      i = i+1
      self.turn = i if role.is_a?(Shogun)
      char = character.to_s.capitalize.constantize.new
      Player.new(role, char, users[i], amount_players)
    end
  end

  def initialize_cards
    Card.initialize_cards.shuffle
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
      save
      handle_game_end
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

  def play_card(source_player, card_name, target_player, what_card)
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
      self.last_error = "Error, #{target.user.username} esta inofensivo" if target.inoffensive
      self.last_error = "Error, #{target.user.username} esta demasiado lejos" if current_player.distance(self.turn, target_index, self) > card.distance
      if self.last_error
        self.log << { player: current_player.user.username, message: self.last_error, type: :error }
        save
        return
      end
      self.pending_answer = []
      self.discarded ||= []
      self.wait_for_answer = true
      self.pending_answer << target
      self.last_action = "#{current_player.user.username} atacó a #{target.user.username} con #{card.friendly_name} - Daño base: #{card.damage + current_player.damage_modifier} - esperando respuesta de #{target.user.username}"
      self.log << { player: current_player.user.username, message: self.last_action, type: :info }
      self.target = target
      self.discarded << current_player.cards.delete_at(card_index)
      self.defend_from = card
      current_player.weapons_played += 1
      update(players: self.players)
      save
      handle_game_end
    when Card::PROPERTY
      self.defend_from = {}
      if card_name == 'bushido'
        if self.bushido_in_play
          self.log << { player: current_player.user.username, message: "Ya hay un Bushido en juego", type: :error }
        else
          target.visible_cards ||= []
          target.visible_cards << current_player.cards.delete_at(card_index)
          self.bushido_in_play = true
          self.last_action = "#{current_player.user.username} jugó #{card.friendly_name} a #{target.user.username}"
          self.log << { player: current_player.user.username, message: self.last_action, type: :info }
        end
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
        self.last_action = "Jugó Ceremonia del Te, recibe 3 cartas y el resto reciben 1"
        self.log << { player: current_player.user.username, message: self.last_action, type: :info }
        self.discarded << current_player.cards.delete_at(card_index)
        save
      when 'distraccion'
        if target && target.cards.any?
          current_player.cards << target.cards.delete(target.cards.sample)
          self.last_action = "Jugó Distracción, roba una carta al azar de la mano de #{target.user.username}"
          self.log << { player: current_player.user.username, message: self.last_action, type: :info }
          self.discarded << current_player.cards.delete_at(card_index)
        else
          self.last_error = "Error, debe elegir un jugador a quien robar la carta" unless target
          self.last_error = "Error, el jugador no posee cartas" unless target.cards.any?
          self.log << { player: current_player.user.username, message: self.last_error, type: :error }
        end
        save
      when 'geisha'
        if target && (what_card == 'from_hand' && target.cards.any? || what_card != 'from_hand')
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
          self.log << { player: current_player.user.username, message: self.last_action, type: :info }
        else
          self.last_error = "Error, debe elegir un jugador a quien robar la carta" unless target
          self.last_error = "Error, debe elegir un jugador con cartas" if what_card == 'from_hand' && target.cards.none?
          self.log << { player: current_player.user.username, message: self.last_eror, type: :error }
        end
        save
      when 'daimio'
        draw_cards(current_player, 2)
        self.last_action = "Jugó Daimio, recibe 2 cartas"
        self.log << { player: current_player.user.username, message: self.last_action, type: :info }
        self.discarded << current_player.cards.delete_at(card_index)
        save
      end
    end
    save
  end

  def take_damage(character)
    if resolve_bushido
      current_player.honor -= 1 unless current_player.role.is_a?(Shogun) && players.size == 3
      self.discarded << current_player.discard_bushido
      self.log << { player: current_player.user.username, message: "Pierde 1 honor debido a Bushido", type: :info }
      self.bushido_in_play = false
      self.resolve_bushido = false
    else
      index = pending_answer.index { |c| c.character.to_s.downcase == character.downcase  }
      player_to_receive_damage = pending_answer.delete_at index
      player_to_receive_damage = find_player_by_character(player_to_receive_damage.character)
      self.wait_for_answer = false if pending_answer.blank?
      self.last_action = "#{player_to_receive_damage.user.username} recibe #{defend_from.damage + current_player.damage_modifier(defend_from)} de daño por #{defend_from.friendly_name}"
      self.log << { player: current_player.user.username, message: self.last_action, type: :info }
      if player_to_receive_damage.take_damage(defend_from.damage, current_player, defend_from)
        handle_action_after_damage(current_player, player_to_receive_damage, defend_from)
      end
    end
    update(players: self.players)
    handle_game_end
    save
  end

  def handle_action_after_damage(current_player, damaged_player, defend_from)
    if current_player.draw_card_after_making_damage?(defend_from.type)
      draw_cards(current_player, 1)
    end

    if damaged_player.draw_card_after_receiving_damage?(defend_from.type)
      draw_cards(damaged_player, 1)
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
    save
  end

  def respond_weapon(character, weapon_name)
    index = pending_answer.index { |c| c.character.to_s.downcase == character.downcase  }
    target = pending_answer.delete_at index
    target = find_player_by_character(target.character)
    if pending_answer.blank?
      self.pending_answer = nil
      self.wait_for_answer = false
    end
    self.last_action = "#{target.user.username} descarto un arma: #{weapon_name.to_s.humanize}"
    self.log << { player: current_player.user.username, message: self.last_action, type: :info }
    self.discarded << target.discard_card(weapon_name)
    save
  end

  def hanzo_ability(character, weapon_name)
    raise "Error, no eres hanzo" unless character == 'hanzo'
    index = pending_answer.index { |c| c.character.to_s.downcase == character.downcase  }
    target = pending_answer.delete_at index
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

  def defend_bushido(weapon_name)
    self.last_action = "Descartó un arma, #{weapon_name.to_s.humanize}, por Bushido"
    self.log << { player: current_player.user.username, message: self.last_action, type: :info }
    self.resolve_bushido = false
    self.discarded << current_player.discard_card(weapon_name)
    transfer_bushido
    save
  end

  def handle_bushido
    if current_player.has_bushido?
      bushido_action_card = self.deck.delete_at(0)
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
    end
    handle_bushido if self.phase == 2
    save
  end
end
