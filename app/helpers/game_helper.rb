module GameHelper
  def next_action(game)
    return if game.game_ended
    case game.phase
    when 1
      button_to "Recuperar Resistencia", reset_resistance_game_path(game.id || 1)
    when 2
      button_to "Robar dos cartas", take_cards_game_path(game.id || 1)
    when 3
      button_to("Jugar Carta", play_card_game_path(game.id || 1)).concat button_to("Finalizar Turno", end_turn_game_path(game.id || 1))
    when 4
      button_to "Descartar cartas en exceso", discard_cards_game_path(game.id || 1)
    end
  end
end
