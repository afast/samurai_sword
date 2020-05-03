class GamesController < ApplicationController
  def index
    @games = current_user.games
  end

  def create
    @game = Game.create
    @game.users << current_user
    redirect_to action: :show, id: @game.id
  end

  def show
    @game = Rails.cache.fetch("game-#{params[:id]}", expires_in: 24.hours) do
      Game.find(params[:id])
    end
    p @game.users
    respond_to do |format|
      format.html { render :show  }
      format.json { render json: @game }
    end
  end

  def new
    @game = Game.new
  end

  def edit
    @game = Game.find(params[:id])
  end

  def start
    @game = Rails.cache.fetch("game-#{params[:id]}", expires_in: 24.hours) do
      Game.find(params[:id])
    end
    @game.start
    @game.save
    p @game.users
    Rails.cache.write("game-#{@game.id}", @game, expires_in: 24.hours)
    GameChannel.broadcast_to(@game, @game)

    respond_to do |format|
      format.html { redirect_to action: :show }
      format.json { render json: @game }
    end
  end

  def join
    @game = Game.find(params[:id])
    @game.users << current_user unless @game.users.include?(current_user)
    p @game.users

    Rails.cache.write("game-#{@game.id}", @game, expires_in: 24.hours)
    GameChannel.broadcast_to(@game, @game)

    respond_to do |format|
      format.html { redirect_to action: :show }
      format.json { render json: @game }
    end
  end

  def destroy
    Game.find(params[:id]).destroy
    redirect_to action: :index
  end

  def admin
    @game = Rails.cache.fetch("game-#{params[:id]}", expires_in: 24.hours) do
      @game = Game.new
      @game.amount_players = 4
      @game.users = [1,2,3,4]
      @game.start
      @game
    end
  end

  def take_cards
    @game = Rails.cache.fetch("game-#{params[:id]}", expires_in: 24.hours) do
      Game.find(params[:id])
    end

    raise "Error, wrong phase to take cards" unless @game.phase == 2
    @game.process_phase
    p @game.users
    Rails.cache.write("game-#{@game.id}", @game, expires_in: 24.hours)
    GameChannel.broadcast_to(@game, @game)
    respond_to do |format|
      format.html { redirect_to admin_game_url(@game.id || 1) }
      format.json { render json: @game }
    end
  end

  def play_card
    @game = Rails.cache.fetch("game-#{params[:id]}", expires_in: 24.hours) do
      Game.find(params[:id])
    end

    raise "Error, wrong phase to play cards" unless @game.phase == 3
    @game.play_card(params[:player], params[:card], params[:target])
    p @game.users
    Rails.cache.write("game-#{@game.id}", @game, expires_in: 24.hours)
    GameChannel.broadcast_to(@game, @game)
    respond_to do |format|
      format.html { redirect_to admin_game_url(@game.id || 1) }
      format.json { render json: @game }
    end
  end

  def reset_resistance
    @game = Rails.cache.fetch("game-#{params[:id]}", expires_in: 24.hours) do
      Game.find(params[:id])
    end

    raise "Error, wrong phase to restore resistance" unless @game.phase == 1
    @game.process_phase
    p @game.users
    Rails.cache.write("game-#{@game.id}", @game, expires_in: 24.hours)
    GameChannel.broadcast_to(@game, @game)
    respond_to do |format|
      format.html { redirect_to admin_game_url(@game.id || 1) }
      format.json { render json: @game }
    end
  end

  def answer_card

    respond_to do |format|
      format.html { redirect_to admin_game_url(@game.id || 1) }
      format.json { render json: @game }
    end
  end

  def end_turn
    @game = Rails.cache.fetch("game-#{params[:id]}", expires_in: 24.hours) do
      Game.find(params[:id])
    end

    raise "Error, wrong phase to take cards" unless @game.phase == 3
    @game.process_phase
    @game.last_error = nil
    @game.last_action = nil
    p @game.users
    Rails.cache.write("game-#{@game.id}", @game, expires_in: 24.hours)
    GameChannel.broadcast_to(@game, @game)
    respond_to do |format|
      format.html { redirect_to admin_game_url(@game.id || 1) }
      format.json { render json: @game }
    end
  end

  def discard_card
    @game = Rails.cache.fetch("game-#{params[:id]}", expires_in: 24.hours) do
      Game.find(params[:id])
    end
    raise "Error, wrong phase to take cards" unless @game.phase == 4
    @game.discard_card(params[:card_name])
    Rails.cache.write("game-#{@game.id}", @game, expires_in: 24.hours)
    GameChannel.broadcast_to(@game, @game)
    respond_to do |format|
      format.html { redirect_to admin_game_url(@game.id || 1) }
      format.json { render json: @game }
    end
  end

  def discard_cards
    @game = Rails.cache.fetch("game-#{params[:id]}", expires_in: 24.hours) do
      Game.find(params[:id])
    end

    raise "Error, wrong phase to take cards" unless @game.phase == 4
    p @game.users
    @game.process_phase
    Rails.cache.write("game-#{@game.id}", @game, expires_in: 24.hours)
    GameChannel.broadcast_to(@game, @game)
    respond_to do |format|
      format.html { redirect_to admin_game_url(@game.id || 1) }
      format.json { render json: @game }
    end
  end

  def take_damage
    @game = Rails.cache.fetch("game-#{params[:id]}", expires_in: 24.hours) do
      Game.find(params[:id])
    end
    raise "Error, you're not waiting to respond" unless @game.pending_answer.map { |p| p.character.to_s.downcase }.include?(params[:character].downcase)
    @game.take_damage(params[:character])
    Rails.cache.write("game-#{@game.id}", @game, expires_in: 24.hours)
    GameChannel.broadcast_to(@game, @game)
    respond_to do |format|
      format.html { redirect_to admin_game_url(@game.id || 1) }
      format.json { render json: @game }
    end
  end

  def play_stop
    @game = Rails.cache.fetch("game-#{params[:id]}", expires_in: 24.hours) do
      Game.find(params[:id])
    end
    raise "Error, you're not waiting to respond" unless @game.pending_answer.map { |p| p.character.to_s.downcase }.include?(params[:character].downcase)
    @game.play_stop(params[:character])
    Rails.cache.write("game-#{@game.id}", @game, expires_in: 24.hours)
    GameChannel.broadcast_to(@game, @game)
    respond_to do |format|
      format.html { redirect_to admin_game_url(@game.id || 1) }
      format.json { render json: @game }
    end
  end

  def discard_weapon
    @game = Rails.cache.fetch("game-#{params[:id]}", expires_in: 24.hours) do
      Game.find(params[:id])
    end
    raise "Error, you're not waiting to respond" unless @game.pending_answer.map { |p| p.character.to_s.downcase }.include?(params[:character].downcase)
    @game.respond_weapon(params[:character], params[:card_name])
    Rails.cache.write("game-#{@game.id}", @game, expires_in: 24.hours)
    GameChannel.broadcast_to(@game, @game)
    respond_to do |format|
      format.html { redirect_to admin_game_url(@game.id || 1) }
      format.json { render json: @game }
    end
  end
end
