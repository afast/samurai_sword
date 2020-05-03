class Game < ApplicationRecord
  STATUS = {
    waiting: 'WAITING',
    started: 'STARTED',
    ended: 'ENDE'
  }

  has_and_belongs_to_many :users

  attr_accessor :amount_players, :hand, :turn, :phase, :wait_for_answer, :game_ended, :samurai_points, :ninja_points,
                :ronin_points, :winning_team
  attr_accessor :players, :deck, :discarded, :pending_answer, :target, :defend_from, :log

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
      roles << Samurai.new
    when 4
      roles << Samurai.new
      roles << Ninja.new
    when 5
      roles << Samurai.new
      roles << Ninja.new
      roles << Ronin.new
    when 6
      roles << Samurai.new
      roles << Ninja.new
      roles += [Ronin.new, Ninja.new]
    when 7
      roles << Samurai.new
      roles << Ninja.new
      roles += [Ronin.new, Ninja.new, Samurai.new]
    end
    roles.shuffle
  end

  def initialize_players
    player_set = CHARACTERS.shuffle.take(@amount_players).zip(determine_roles(@amount_players))
    i=-1
    player_set.map do |character, role|
      i = i+1
      @turn = i if role.is_a?(Shogun)
      char = character.to_s.capitalize.constantize.new
      Player.new(role, char, users[i], @amount_players)
    end
  end

  def initialize_cards
    Card.initialize_cards.shuffle
  end

  def start
    return unless self.status == STATUS[:waiting]
    @amount_players = users.size
    @players = initialize_players
    @deck = initialize_cards
    @game_ended = false
    @log = [{player: 'System', message: 'Inicio del Juego', type: :info}]
    @phase = 2
    i = 0
    while i < @players.size do
      @players[(@turn + i) % @players.size].cards = @deck.slice!(0, INITIAL_AMOUNT_CARDS[i])
      i+= 1
    end
    @discarded = []
    @hand = 0
    update status: STATUS[:started], amount_players: @amount_players, players: @players, deck: @deck, game_ended: false, phase: 2, discarded: @discarded, hand: 0
  end

  def discard_card(card_name)
    p card_name
    index = current_player.cards.index { |c| c.name.to_s.downcase == card_name  }
    @discarded << current_player.cards.delete_at(index)
    @log << { player: current_player.user.username, message: "Descartó #{card_name}", type: :info }
    update discarded: @discarded, users: users
    if current_player.cards.size <= 7
      next_phase
    end
  end

  def current_state
    if @game_ended
      "Game Ended"
    else
      "#{current_player.character} - #{current_player.role} | Phase #{@phase}"
    end
  end

  def current_player
    @players[@turn]
  end

  def all_other_players
    @players.slice(0, @turn) + @players.slice(@turn+1, @players.size-1)
  end

  def all_other_offensive_players
    all_other_players.select { |p| !p.inoffensive }
  end

  def handle_deck_zero
    @deck = @discarded.shuffle
    @discarded = []
    @players.map { |p| p.honor -= 1 }
    @log << { player: current_player.user.username, message: "Se acabo el mazo, todos pierden un punto de honor", type: :info }
    handle_game_end
  end

  def handle_game_end
    @game_ended = @players.collect(&:dead?).inject(:|)
    @samurai_points = 0
    @ninja_points = 0
    @ronin_points = 0
    first_ninja=true
    @players.each do |p|
      case p.role
      when Shogun
        @samurai_points += p.honor
      when Samurai
        @samurai_points += (@amount_players % 2 == 0) ? p.honor*2 : p.honor
      when Ninja
        if @amount_players == 4 && first_ninja
          @ninja_points += p.honor*2
        else
          @ninja_points += p.honor
        end
      when Ronin
        if @amount_players == 5
          @ronin_points = p.honor*2
        elsif @amount_players > 5
          @ronin_points = p.honor*3
        end
      end
    end

    if @samurai_points > @ninja_points && @samurai_points >= @ronin_points
      @winning_team = 'Shogun/Samurais'
    elsif @ninja_points >= @samurai_points && @ninja_points >= @ronin_points
      @winning_team = 'Ninjas'
    else
      @winning_team = 'Ronin'
    end
  end

  def draw_cards(player, amount)
    return if @game_ended
    player.cards += @deck.slice!(0, amount)
    handle_deck_zero if @deck.size.zero?
  end

  def process_phase
    return if @game_ended
    update(last_action: nil, last_error: nil)
    if @phase == 1
      if current_player.resistance <= 0
        current_player.reset_resistance
        @log << { player: current_player.user.username, message: "Recupero Resistencia", type: :info }
      end
    end
    case @phase
    when 2
      @hand += 1 if current_player.role.is_a? Shogun
      current_player.weapons_played = 0
      draw_cards(current_player, 2)
      @log << { player: current_player.user.username, message: "Robo 2 cartas", type: :info }
    when 4
      if current_player.cards.size > 7
        @discarded += current_player.cards.slice!(7, Card::WEAPONS.size)
      end
      current_player.cleanup_turn
      next_turn
      next_phase unless current_player.resistance <= 0
    end
    next_phase
  end

  def next_turn
    return if @game_ended
    @log << { player: current_player.user.username, message: "Finalizo Turno", type: :info }
    @turn = (@turn + 1) % @amount_players
    @log << { player: current_player.user.username, message: "Comienzo Turno", type: :info }
    update(last_action: nil, last_error: nil, log: @log)
  end

  def find_player_by_character(character)
    @players.detect { |p| p.character.to_s.downcase == character.downcase }
  end

  def play_card(source_player, card_name, target_player)
    return if @game_ended
    @last_action = nil
    @last_error = nil
    current_player = find_player_by_character(source_player)
    if target_player
      target = find_player_by_character(target_player)
      target_index = @players.index(target)
    end
    card_index = current_player.cards.index { |c| c.name.to_s == card_name.downcase }
    card = current_player.cards[card_index]
    case card.type
    when Card::WEAPON
      @last_error = "Error, no player for index" unless target
      @last_error = "Error, #{current_player.user.username} no puede jugar mas armas" unless current_player.can_play_weapon?
      @last_error = "Error, #{target.user.username} esta inofensivo" if target.inoffensive
      @last_error = "Error, #{target.user.username} esta demasiado lejos" if current_player.distance(@turn, target_index, self) > card.distance
      if @last_error
        @log << { player: current_player.user.username, message: @last_error, type: :error }
        update(last_error: @last_error, last_action: @last_action, log: @log)
        return
      end
      @pending_answer = []
      @discarded ||= []
      @wait_for_answer = true
      @pending_answer << target
      @last_action = "Atacó #{target.user.username} con #{card.friendly_name} - Daño: #{card.damage + current_player.damage_modifier} - esperando respuesta de #{target.user.username}"
      @log << { player: current_player.user.username, message: @last_action, type: :info }
      @target = target
      update(wait_for_answer: @wait_for_answer, defend_from: card, pending_answer: @pending_answer, last_action: @last_action, target: @target, log: @log)
      @discarded << current_player.cards.delete_at(card_index)
      update(discarded: @discarded)
      current_player.weapons_played += 1
      handle_game_end
    when Card::PROPERTY
      current_player.visible_cards ||= []
      current_player.visible_cards << current_player.cards.delete_at(card_index)
      @last_action = "Bajó #{card.friendly_name} a la mesa"
      @log << { player: current_player.user.username, message: @last_action, type: :info }
      update(log: @log)
    when Card::ACTION
      case card_name
      when 'respiracion'
        if target
          current_player.reset_resistance!
          draw_cards(target, 1)
          @last_action = "Respiracion - #{current_player.character} recupero resistencia y #{target.character} robo una carta"
          @log << { player: current_player.user.username, message: @last_action, type: :info }
          @discarded << current_player.cards.delete_at(card_index)
        else
          @last_error = "Error, debe elegir un jugador para recibir la carta"
          @log << { player: current_player.user.username, message: @last_error, type: :error }
        end
        update(discarded: @discarded, log: @log)
      when 'jiujitsu'
        @pending_answer = []
        @last_action = "Jugó Jiu-Jitsu, todos los demas descartan un arma o pierden 1 de resistencia"
        @log << { player: current_player.user.username, message: @last_action, type: :info }
        all_other_offensive_players.each do |p|
          @pending_answer << p
        end
        @discarded << current_player.cards.delete_at(card_index)
        update(discarded: @discarded, last_action: @last_action, defend_from: card, pending_answer: @pending_answer, log: @log)
        handle_game_end
      when 'grito_de_batalla'
        @pending_answer = []
        @last_action = "Jugó Grito de Batalla, todos los demas descartan una parada o pierden 1 de resistencia"
        @log << { player: current_player.user.username, message: @last_action, type: :info }
        all_other_offensive_players.each do |p|
          @pending_answer << p
        end
        @discarded << current_player.cards.delete_at(card_index)
        update(discarded: @discarded, last_action: @last_action, defend_from: card, pending_answer: @pending_answer, log: @log)
        handle_game_end
      when 'ceremonia_del_te'
        draw_cards(current_player, 3)
        all_other_players.each { |p| draw_cards(p, 1) }
        @last_action = "Jugó Ceremonia del Te, recibe 3 cartas y el resto reciben 1"
        @log << { player: current_player.user.username, message: @last_action, type: :info }
        @discarded << current_player.cards.delete_at(card_index)
        update(discarded: @discarded, deck: @deck, last_action: @last_action, log: @log)
      when 'distraccion'
        if target
          current_player.cards << target.cards.delete(target.cards.sample)
          @last_action = "Jugó Distracción, roba una carta al azar de la mano de #{target.user.username}"
          @log << { player: current_player.user.username, message: @last_action, type: :info }
          @discarded << current_player.cards.delete_at(card_index)
        else
          @last_error = "Error, debe eleginr un jugador a quien robar la carta"
          @log << { player: current_player.user.username, message: @last_eror, type: :error }
        end
        update(discarded: @discarded, last_action: @last_action, log: @log)
      when 'geisha'
        if target
          @discarded << target.cards.delete(target.cards.sample)
          @last_action = "Jugó Geisha, descartó (al azar) #{@discarded.last.friendly_name} de la mano de #{target.user.username}"
          @log << { player: current_player.user.username, message: @last_action, type: :info }
          @discarded << current_player.cards.delete_at(card_index)
        else
          @last_error = "Error, debe eleginr un jugador a quien robar la carta"
          @log << { player: current_player.user.username, message: @last_eror, type: :error }
        end
        update(discarded: @discarded, last_action: @last_action, log: @log)
      when 'daimio'
        draw_cards(current_player, 2)
        @last_action = "Jugó Daimio, recibe 2 cartas"
        @log << { player: current_player.user.username, message: @last_action, type: :info }
        @discarded << current_player.cards.delete_at(card_index)
        update(discarded: @discarded, deck: @deck, last_action: @last_action, log: @log)
      end
    end
    save
  end

  def take_damage(character)
    index = pending_answer.index { |c| c.character.to_s.downcase == character.downcase  }
    player_to_receive_damage = pending_answer.delete_at index
    @wait_for_answer = false if pending_answer.blank?
    @last_action = "#{player_to_receive_damage.user.username} recibe #{defend_from.damage + current_player.damage_modifier(defend_from)} de daño por #{defend_from.friendly_name}"
    @log << { player: current_player.user.username, message: @last_action, type: :info }
    player_to_receive_damage.take_damage(defend_from.damage, current_player, defend_from)
    handle_game_end
    update(last_action: @last_action, pending_answer: @pending_answer, wait_for_answer: @wait_for_answer, log: @log)
  end

  def play_stop(character)
    index = pending_answer.index { |c| c.character.to_s.downcase == character.downcase  }
    player_to_receive_damage = pending_answer.delete_at index
    if pending_answer.blank?
      @pending_answer = nil
      @wait_for_answer = false
    end
    @last_action = "Atacó #{player_to_receive_damage.user.username} con #{defend_from.friendly_name} pero fue defendido."
    @log << { player: current_player.user.username, message: @last_action, type: :info }
    @discarded << player_to_receive_damage.discard_stop_card
    update(last_action: @last_action, pending_answer: @pending_answer, wait_for_answer: @wait_for_answer, discarded: @discarded, log: @log)
  end

  def respond_weapon(character, weapon_name)
    index = pending_answer.index { |c| c.character.to_s.downcase == character.downcase  }
    target = pending_answer.delete_at index
    if pending_answer.blank?
      @pending_answer = nil
      @wait_for_answer = false
    end
    @last_action = "#{target.user.username} descarto un arma: #{weapon_name.to_s.humanize}"
    @log << { player: current_player.user.username, message: @last_action, type: :info }
    @discarded << target.discard_card(weapon_name)
    update(last_action: @last_action, pending_answer: @pending_answer, wait_for_answer: @wait_for_answer, discarded: @discarded, log: @log)
  end

  def reset_resistance_for_current_player
    current_player.reset_resistance
  end

  def next_phase
    return if @game_ended
    case @phase
    when 1
      @phase = 2
    when 2
      @phase = 3
    when 3
      if current_player.cards.size > 7
        @phase = 4
      else
        next_turn
        if current_player.resistance <= 0
          @phase = 1
        else
          @phase = 2
        end
      end
    when 4
      next_turn
      if current_player.resistance <= 0
        @phase = 1
      else
        @phase = 2
      end
    end
    update phase: @phase, turn: @turn
  end
end
